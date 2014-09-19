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
#import "UIImageView+WebCache.h"
#import "DWTagList.h"

// Categories
#import "UIViewController+Extras.h"
#import "UIImage+Color.h"

// Custom UI
#import "PXAlertView.h"

@interface RYProfileInfoTableViewCell () <DWTagListDelegate, UIGestureRecognizerDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *imageWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *userActionButton;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet DWTagList *tagListView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

@property (weak, nonatomic) IBOutlet UIView *karmaWrapperView;
@property (weak, nonatomic) IBOutlet UILabel *karmaCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *karmaImageView;

@property (weak, nonatomic) IBOutlet UIView *followersWrapperView;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *followersImageView;

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
    
    [_nameField setFont:[UIFont fontWithName:kRegularFont size:28.0f]];
    [_usernameLabel setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    [_bioTextView setFont:kProfileInfoCellFont];
    _nameField.textColor = [RYStyleSheet darkTextColor];
    _usernameLabel.textColor = [RYStyleSheet darkTextColor];
    _bioTextView.textColor = [RYStyleSheet darkTextColor];
    [_bioTextView setTintColor:[RYStyleSheet darkTextColor]];
    
    [_avatarImageView setBackgroundColor:[RYStyleSheet tabBarColor]];
    [RYStyleSheet styleProfileImageView:_avatarImageView];
    
    [_followersCountLabel setFont:[UIFont fontWithName:kRegularFont size:20.0f]];
    [_followersCountLabel setTextColor:[RYStyleSheet darkTextColor]];
    [_followersImageView setImage:[[UIImage imageNamed:@"stream"] colorImage:[RYStyleSheet darkTextColor]]];
    
    [_karmaCountLabel setFont:[UIFont fontWithName:kRegularFont size:20.0f]];
    [_karmaCountLabel setTextColor:[RYStyleSheet darkTextColor]];
    [_karmaImageView setImage:[[UIImage imageNamed:@"upvote"] colorImage:[RYStyleSheet darkTextColor]]];
    
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editImageTapped:)];
    [_avatarImageView addGestureRecognizer:avatarTap];
    
    UITapGestureRecognizer *followersTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followersTapped:)];
    [_followersWrapperView addGestureRecognizer:followersTap];
    
    [_nameField setDelegate:self];
    [_bioTextView setDelegate:self];
    
    [_tagListView setAutomaticResize:YES];
    [_tagListView setTagDelegate:self];
    [_tagListView setBorderWidth:0.0f];
    [_tagListView setTagBackgroundColor:[UIColor clearColor]];
    [_tagListView setTextShadowColor:[UIColor clearColor]];
    [_tagListView setFont:[UIFont fontWithName:kRegularFont size:16.0f]];
    [_tagListView setTextColor:[RYStyleSheet postActionColor]];
}

- (void) configureForUser:(RYUser *)user delegate:(id<ProfileInfoCellDelegate, UpdateUserDelegate>)delegate parentTableView:(UITableView *)tableView
{
    _user              = user;
    _delegate          = delegate;

    // configure for editing if looking at the logged in user's profile
    _isLoggedInProfile = (user && (user.userId == [RYRegistrationServices loggedInUser].userId));
    _forProfileTab     = NO;
    
    // Profile picture
    if (user.avatarURL)
        [_avatarImageView sd_setImageWithURL:user.avatarURL placeholderImage:[UIImage imageNamed:@"user"]];
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
    
    [_usernameLabel setEnabled:YES];
    [_bioTextView setEditable:YES];
    
    _forProfileTab = YES;
}

#pragma mark - Styling

- (void) styleFollowing:(BOOL)following
{
    UIColor *followColor  = following ? [RYStyleSheet postActionColor] : [RYStyleSheet availableActionColor];
    NSString *followImage = following ? @"stream" : @"availableStream";
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
    if (![_bioTextView.text isEqualToString:[RYRegistrationServices loggedInUser].bio])
    {
        // bio changed
        RYUser *newUser = [[RYRegistrationServices loggedInUser] copy];
        [newUser setBio:textView.text];
        [[RYRegistrationServices sharedInstance] editUserInfo:newUser forDelegate:_delegate];
    }
}

#pragma mark - TextField Delegate

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (![_nameField.text isEqualToString:[RYRegistrationServices loggedInUser].nickname])
    {
        // bio changed
        RYUser *newUser = [[RYRegistrationServices loggedInUser] copy];
        newUser.nickname = _nameField.text;
        [[RYRegistrationServices sharedInstance] editUserInfo:newUser forDelegate:_delegate];
    }
}

#pragma mark -
#pragma mark - DWTagList Delegate

- (void) selectedTag:(NSString *)tagName tagIndex:(NSInteger)tagIndex
{
    if (_forProfileTab)
    {
        [PXAlertView showAlertWithTitle:@"Remove Tag" message:[NSString stringWithFormat:@"Remove %@ from profile?",tagName] cancelTitle:@"Cancel" otherTitle:@"Remove" completion:^(BOOL cancelled, NSInteger buttonIndex, NSString *inputValue) {
            if (!cancelled)
            {
                // remove tag
                RYUser *userCopy = [_user copy];
                NSMutableArray *mutTags = [userCopy.tags mutableCopy];
                [mutTags removeObjectAtIndex:tagIndex];
                userCopy.tags = mutTags;
                [[RYRegistrationServices sharedInstance] editUserInfo:userCopy forDelegate:_delegate];
            }
        }];
    }
    else if (_delegate && [_delegate respondsToSelector:@selector(tagSelected:)])
        [_delegate tagSelected:tagIndex];
}

- (void) selectedAddTag
{
    [PXAlertView showInputAlertWithTitle:@"Add Tag" message:nil placeholder:@"New Tag" cancelTitle:@"Cancel" otherTitle:@"Add" completion:^(BOOL cancelled, NSInteger buttonIndex, NSString *inputValue)
     {
         if (!cancelled && inputValue.length > 0)
         {
             RYTag *newTag = [[RYTag alloc] initWithTag:[inputValue lowercaseString] numUsers:0 numPosts:0];
             RYUser *userCopy = [_user copy];
             userCopy.tags = [userCopy.tags arrayByAddingObject:newTag];
             [[RYRegistrationServices sharedInstance] editUserInfo:userCopy forDelegate:_delegate];
         }
    }];
}

@end
