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

// Frameworks
#import "UIImageView+SGImageCache.h"
#import "DWTagList.h"

// Categories
#import "UIViewController+Extras.h"

@interface RYProfileInfoTableViewCell () <UIGestureRecognizerDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *imageWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *editImageLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *addRiffButton;
@property (weak, nonatomic) IBOutlet DWTagList *tagListView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet UIView *karmaWrapperView;
@property (weak, nonatomic) IBOutlet UILabel *karmaCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *karmaDescriptionLabel;

@property (weak, nonatomic) IBOutlet UIView *followersWrapperView;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersDescriptionLabel;

// Data
@property (nonatomic, weak) id<ProfileInfoCellDelegate, UpdateUserDelegate> delegate;
@property (nonatomic, weak) UITableView *parentTable;
@property (nonatomic, assign) BOOL isLoggedInProfile;

@end

@implementation RYProfileInfoTableViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [_nameField setFont:[UIFont fontWithName:kRegularFont size:36.0f]];
    [_usernameLabel setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    [_bioTextView setFont:kProfileInfoCellFont];
    
    [_addRiffButton setTintColor:[RYStyleSheet audioActionColor]];
    
    [_editImageLabel setFont:[UIFont fontWithName:kLightFont size:20.0f]];
    [_editImageLabel setTextColor:[UIColor whiteColor]];
    [_editImageLabel setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.6]];
    [_imageWrapperView setBackgroundColor:[RYStyleSheet foregroundColor]];
    [_imageWrapperView.layer setCornerRadius:_imageWrapperView.frame.size.width/8];
    [_imageWrapperView setClipsToBounds:YES];
    
    [_followersCountLabel setFont:[UIFont fontWithName:kRegularFont size:20.0f]];
    [_followersDescriptionLabel setFont:[UIFont fontWithName:kLightFont size:18.0f]];
    
    [_karmaCountLabel setFont:[UIFont fontWithName:kRegularFont size:20.0f]];
    [_karmaDescriptionLabel setFont:[UIFont fontWithName:kLightFont size:18.0f]];
    
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editImageTapped:)];
    [_imageWrapperView addGestureRecognizer:avatarTap];
    
    UITapGestureRecognizer *followersTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followersTapped:)];
    [_followersWrapperView addGestureRecognizer:followersTap];
    
    [_nameField setDelegate:self];
    [_bioTextView setDelegate:self];
    
    // test tags
    [_tagListView setAutomaticResize:YES];
    NSArray *tags = [[NSMutableArray alloc] initWithObjects:@"Foo",
              @"Tag Label 1",
              @"Tag Label 2",
              @"Tag Label 3",
              @"Tag Label 4",
              @"Long long long long long long Tag", nil];
    [_tagListView setTags:tags];
}

- (void) configureForUser:(RYUser *)user delegate:(id<ProfileInfoCellDelegate, UpdateUserDelegate>)delegate parentTableView:(UITableView *)tableView
{
    _delegate = delegate;
    
    // configure for editing if looking at the logged in user's profile
    _isLoggedInProfile = (user && (user.userId == [RYServices loggedInUser].userId));
    
    // Profile picture
    if (user.avatarURL)
        [_avatarImageView setImageForURL:user.avatarURL placeholder:[UIImage imageNamed:@"user"]];
    else
        [_avatarImageView setImage:[UIImage imageNamed:@"user"]];
    
    if (user.nickname.length > 0 && ![user.nickname isEqualToString:user.username])
    {
        [_nameField setText:user.nickname];
        [_usernameLabel setText:[NSString stringWithFormat:@"@%@",user.username]];
    }
    else
    {
        [_nameField setText:user.username];
        [_usernameLabel setText:@""];
    }
    [_bioTextView setText:user.bio];
    [_karmaCountLabel setText:[NSString stringWithFormat:@"%ld",(long)user.karma]];
    [_followersCountLabel setText:[NSString stringWithFormat:@"%ld",(long)user.numFollowers]];
    
    if (user.userId == [RYServices loggedInUser].userId)
    {
        [_editImageLabel setHidden:NO];
        [_settingsButton setHidden:NO];
        
        [_bioTextView setEditable:YES];
        [_nameField setEnabled:YES];
    }
    else
    {
        // not logged in user, remove settings button
        [_editImageLabel setHidden:YES];
        [_settingsButton setHidden:YES];
        
        [_bioTextView setEditable:NO];
        [_nameField setEnabled:NO];
    }
}

#pragma mark - Actions

- (IBAction)settingsButtonHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(settingsAction:)])
        [_delegate settingsAction:_settingsButton.frame];
}

- (IBAction)addRiffButtonHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(addNewRiff)])
        [_delegate addNewRiff];
}

- (void) editImageTapped:(UITapGestureRecognizer *)tapGesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(editImageAction)])
        [_delegate editImageAction];
}

- (void) followersTapped:(UITapGestureRecognizer *)tapGesture
{
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

@end
