//
//  RYProfileInfoTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 7/23/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYProfileInfoTableViewCell.h"

// Data Managers
#import "RYStyleSheet.h"

// Data Objects
#import "RYUser.h"
#import "RYTag.h"

// Frameworks
#import "UIImageView+SGImageCache.h"
#import "DWTagList.h"

// Categories
#import "UIViewController+Extras.h"

// Custom UI
#import "BlockAlertView.h"

@interface RYProfileInfoTableViewCell () <DWTagListDelegate, UIGestureRecognizerDelegate, UITextViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *imageWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *userActionButton;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet DWTagList *tagListView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

@property (weak, nonatomic) IBOutlet UIView *karmaWrapperView;
@property (weak, nonatomic) IBOutlet UILabel *karmaCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *karmaDescriptionLabel;

@property (weak, nonatomic) IBOutlet UIView *followersWrapperView;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersDescriptionLabel;

// Data
@property (nonatomic, strong) RYUser *user;
@property (nonatomic, weak) id<ProfileInfoCellDelegate, UpdateUserDelegate> delegate;
@property (nonatomic, weak) UITableView *parentTable;
@property (nonatomic, assign) BOOL isLoggedInProfile;
@property (nonatomic, assign) BOOL forProfileTab;

@end

@implementation RYProfileInfoTableViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [_nameField setFont:[UIFont fontWithName:kRegularFont size:36.0f]];
    [_usernameLabel setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    [_bioTextView setFont:kProfileInfoCellFont];
    
    [_avatarImageView setBackgroundColor:[RYStyleSheet tabBarColor]];
    [RYStyleSheet styleProfileImageView:_avatarImageView];
    
    [_followersCountLabel setFont:[UIFont fontWithName:kRegularFont size:20.0f]];
    [_followersDescriptionLabel setFont:[UIFont fontWithName:kLightFont size:18.0f]];
    
    [_karmaCountLabel setFont:[UIFont fontWithName:kRegularFont size:20.0f]];
    [_karmaDescriptionLabel setFont:[UIFont fontWithName:kLightFont size:18.0f]];
    
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editImageTapped:)];
    [_avatarImageView addGestureRecognizer:avatarTap];
    
    UITapGestureRecognizer *followersTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followersTapped:)];
    [_followersWrapperView addGestureRecognizer:followersTap];
    
    [_nameField setDelegate:self];
    [_bioTextView setDelegate:self];
    
    [_tagListView setAutomaticResize:YES];
    [_tagListView setTagDelegate:self];
}

- (void) configureForUser:(RYUser *)user delegate:(id<ProfileInfoCellDelegate, UpdateUserDelegate>)delegate parentTableView:(UITableView *)tableView
{
    _user              = user;
    _delegate          = delegate;

    // configure for editing if looking at the logged in user's profile
    _isLoggedInProfile = (user && (user.userId == [RYServices loggedInUser].userId));
    _forProfileTab     = NO;
    
    // Profile picture
    if (user.avatarURL)
        [_avatarImageView setImageForURL:user.avatarURL.absoluteString placeholder:[UIImage imageNamed:@"user"]];
    else
        [_avatarImageView setImage:[UIImage imageNamed:@"user"]];
    
    if (_isLoggedInProfile)
    {
        [_userActionButton setHidden:YES];
        [_messageButton setHidden:YES];
    }
    else
    {
        [_userActionButton setHidden:NO];
        [self styleFollowing:_user.isFollowing];
        
        [_messageButton setHidden:NO];
        [_messageButton setTintColor:[RYStyleSheet availableActionColor]];
    }
    
    if (user.nickname.length > 0 && ![user.nickname isEqualToString:user.username])
    {
        [_nameField setText:user.nickname];
        [_usernameLabel setText:[NSString stringWithFormat:@"@%@",user.username]];
    }
    else
    {
        [_nameField setText:[NSString stringWithFormat:@"@%@",user.username]];
        [_usernameLabel setText:@""];
    }
    [_bioTextView setText:user.bio];
    [_karmaCountLabel setText:[NSString stringWithFormat:@"%ld",(long)user.karma]];
    [_followersCountLabel setText:[NSString stringWithFormat:@"%ld",(long)user.numFollowers]];
    [_tagListView setTags:[RYTag getTagTags:user.tags]];
    
    [_bioTextView setEditable:NO];
    [_nameField setEnabled:NO];
    [_avatarImageView setUserInteractionEnabled:NO];
    
    [self setBackgroundColor:[UIColor clearColor]];
}

// options only for logged in user in profile tab. Should be called after configureForUser: when preparing for display
- (void) enableUserSettingOptions
{
    [_bioTextView setEditable:YES];
    [_nameField setEnabled:YES];
    [_avatarImageView setUserInteractionEnabled:YES];
    
    [_userActionButton setHidden:NO];
    [_userActionButton setImage:[UIImage imageNamed:@"options"] forState:UIControlStateNormal];
    [_userActionButton setTintColor:[RYStyleSheet availableActionColor]];
    
    [_messageButton setHidden:NO];
    [_messageButton setTintColor:[RYStyleSheet postActionColor]];
    
    [_tagListView addAddNewTagTag];
    
    _forProfileTab = YES;
}

#pragma mark - Styling

- (void) styleFollowing:(BOOL)following
{
    UIColor *followColor  = following ? [RYStyleSheet postActionColor] : [RYStyleSheet availableActionColor];
    NSString *followImage = following ? @"userDelete" : @"userAdd";
    [_userActionButton setImage:[UIImage imageNamed:followImage] forState:UIControlStateNormal];
    [_userActionButton setTintColor:followColor];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)userActionButtonHit:(id)sender
{
    if (_forProfileTab)
    {
        // tapped settings button
        CGRect convertedFrame = [self convertRect:_userActionButton.frame fromView:_imageWrapperView];
        if (_delegate && [_delegate respondsToSelector:@selector(settingsAction:)])
            [_delegate settingsAction:convertedFrame];
    }
    else
    {
        // tapped follow button
        if (_delegate && [_delegate respondsToSelector:@selector(followAction)])
            [_delegate followAction];
    }
}

- (IBAction)messageButtonHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageAction)])
        [_delegate messageAction];
}

- (void) editImageTapped:(UITapGestureRecognizer *)tapGesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(editImageAction)])
        [_delegate editImageAction];
}

- (void) followersTapped:(UITapGestureRecognizer *)tapGesture
{
    [self styleFollowing:!_user.isFollowing];
    
    if (_delegate && [_delegate respondsToSelector:@selector(followersAction)])
        [_delegate followersAction];
}

#pragma mark -
#pragma mark - TextView Delegate

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if (![_bioTextView.text isEqualToString:[RYServices loggedInUser].bio])
    {
        // bio changed
        RYUser *newUser = [[RYServices loggedInUser] copy];
        [newUser setBio:textView.text];
        [[RYServices sharedInstance] editUserInfo:newUser forDelegate:_delegate];
    }
}

#pragma mark - TextField Delegate

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (![_nameField.text isEqualToString:[RYServices loggedInUser].nickname])
    {
        // bio changed
        RYUser *newUser = [[RYServices loggedInUser] copy];
        newUser.nickname = _nameField.text;
        [[RYServices sharedInstance] editUserInfo:newUser forDelegate:_delegate];
    }
}

#pragma mark -
#pragma mark - DWTagList Delegate

- (void) selectedTag:(NSString *)tagName tagIndex:(NSInteger)tagIndex
{
    if (_forProfileTab)
    {
        BlockAlertView *removeTagAlert = [[BlockAlertView alloc] initWithTitle:@"Remove Tag" message:[NSString stringWithFormat:@"Remove %@ from profile?",tagName] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", nil];
        [removeTagAlert setDidDismissBlock:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != alertView.cancelButtonIndex)
            {
                // remove tag
                RYUser *userCopy = [_user copy];
                NSMutableArray *mutTags = [userCopy.tags mutableCopy];
                [mutTags removeObjectAtIndex:tagIndex];
                userCopy.tags = mutTags;
                [[RYServices sharedInstance] editUserInfo:userCopy forDelegate:_delegate];
            }
        }];
        [removeTagAlert show];
    }
    else if (_delegate && [_delegate respondsToSelector:@selector(tagSelected:)])
        [_delegate tagSelected:tagIndex];
}

- (void) selectedAddTag
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Tag" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark -
#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *tagText =  [alertView textFieldAtIndex: 0].text;
    if (buttonIndex == 1 && tagText.length > 0)
    {
        RYTag *newTag = [[RYTag alloc] initWithTag:tagText numUsers:0 numPosts:0];
        RYUser *userCopy = [_user copy];
        userCopy.tags = [userCopy.tags arrayByAddingObject:newTag];
        [[RYServices sharedInstance] editUserInfo:userCopy forDelegate:_delegate];
    }
}

@end
