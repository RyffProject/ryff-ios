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
#import "RYServices.h"

// Data Objects
#import "RYUser.h"

// Frameworks
#import "UIImageView+SGImageCache.h"

@interface RYProfileInfoTableViewCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *imageWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *editImageLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addRiffButton;

// Data
@property (nonatomic, weak) id<ProfileInfoCellDelegate> delegate;
@property (nonatomic, weak) UITableView *parentTable;
@property (nonatomic, assign) BOOL isLoggedInProfile;

@end

@implementation RYProfileInfoTableViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [_nameLabel setFont:[UIFont fontWithName:kRegularFont size:36.0f]];
    [_bioTextView setFont:kProfileInfoCellFont];
    
    [_addRiffButton setTintColor:[RYStyleSheet actionColor]];
    
    [_editImageLabel setFont:[UIFont fontWithName:kLightFont size:20.0f]];
    [_editImageLabel setTextColor:[UIColor whiteColor]];
    [_editImageLabel setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.4]];
    [_imageWrapperView setBackgroundColor:[RYStyleSheet foregroundColor]];
    [_imageWrapperView.layer setCornerRadius:_imageWrapperView.frame.size.width/8];
    [_imageWrapperView setClipsToBounds:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editImageTapped:)];
    [_imageWrapperView addGestureRecognizer:tapGesture];
}

- (void) configureForUser:(RYUser *)user delegate:(id<ProfileInfoCellDelegate>)delegate parentTableView:(UITableView *)tableView
{
    _delegate = delegate;
    
    // configure for editing if looking at the logged in user's profile
    _isLoggedInProfile = (user && (user.userId == [RYServices loggedInUser].userId));
    
    // Profile picture
    if (user.avatarURL)
        [_avatarImageView setImageForURL:user.avatarURL placeholder:[UIImage imageNamed:@"user"]];
    else
        [_avatarImageView setImage:[UIImage imageNamed:@"user"]];
    
    NSString *userString = (user && user.nickname.length > 0) ? user.nickname : user.username;
    [_nameLabel setText:userString];
    [_bioTextView setText:user.bio];
    
    if (user.userId == [RYServices loggedInUser].userId)
    {
        [_editImageLabel setHidden:NO];
        [_settingsButton setHidden:NO];
    }
    else
    {
        // not logged in user, remove settings button
        [_editImageLabel setHidden:YES];
        [_settingsButton setHidden:YES];
    }
}

#pragma mark - Actions

- (IBAction)settingsButtonHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(settingsAction:)])
    {
        [_delegate settingsAction:_settingsButton.frame];
    }
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

@end
