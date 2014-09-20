//
//  RYUserListCollectionViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/19/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYUserListCollectionViewCell.h"

// Data Managers
#import "RYStyleSheet.h"
#import "RYRegistrationServices.h"

// Data Objects
#import "RYUser.h"
#import "RYTag.h"

// Custom UI
#import "DWTagList.h"

// Categories
#import "UIImageView+WebCache.h"
#import "UIImage+Color.h"

@interface RYUserListCollectionViewCell () <DWTagListDelegate>

@property (weak, nonatomic) IBOutlet UIView *avatarWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UIView *detailsWrapperView;
@property (weak, nonatomic) IBOutlet UIView *upvotesContainerView;
@property (weak, nonatomic) IBOutlet UILabel *upvoteCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *upvoteImageView;
@property (weak, nonatomic) IBOutlet UIView *followersContainerView;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *followersImageView;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet DWTagList *tagListView;

// Data
@property (nonatomic, strong) RYUser *user;

@end

@implementation RYUserListCollectionViewCell

- (void) configureWithUser:(RYUser *)user delegate:(id<UserListCellDelegate>)delegate
{
    _user = user;
    _delegate = delegate;
    
    if (user.avatarURL)
        [_avatarImageView sd_setImageWithURL:user.avatarURL placeholderImage:[UIImage imageNamed:@"user"]];
    else
        [_avatarImageView setImage:[UIImage imageNamed:@"user"]];
    
    NSString *username = (user.nickname && user.nickname.length > 0) ? user.nickname : user.username;
    _userLabel.text = username;
    
    _upvoteCountLabel.text = [NSString stringWithFormat:@"%ld",(long)user.karma];
    _followersCountLabel.text = [NSString stringWithFormat:@"%ld",(long)user.numFollowers];
    
    [self styleFollowing:user.isFollowing];
    
    _bioTextView.text = user.bio;
    [_tagListView setTags:[RYTag getTagTags:user.tags]];
}

- (void) styleFollowing:(BOOL)following
{
    if (_user.userId == [RYRegistrationServices loggedInUser].userId)
    {
        // current user
        _followButton.hidden = YES;
        return;
    }
    else
        _followButton.hidden = NO;
    
    if (following)
    {
        [_followButton setImage:[UIImage imageNamed:@"stream"] forState:UIControlStateNormal];
        _followButton.tintColor = [RYStyleSheet postActionColor];
    }
    else
    {
        [_followButton setImage:[UIImage imageNamed:@"availableStream"] forState:UIControlStateNormal];
        _followButton.tintColor = [RYStyleSheet availableActionColor];
    }
}

#pragma mark -
#pragma mark - LifeCycle

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [RYStyleSheet styleProfileImageView:_avatarImageView];
    _followersImageView.image = [[UIImage imageNamed:@"stream"] colorImage:[RYStyleSheet darkTextColor]];
    _upvoteImageView.image = [[UIImage imageNamed:@"upvote"] colorImage:[RYStyleSheet darkTextColor]];
    
    _userLabel.textColor = _upvoteCountLabel.textColor = _followersCountLabel.textColor = _bioTextView.textColor = [RYStyleSheet darkTextColor];
    
    _bioTextView.font = [UIFont fontWithName:kRegularFont size:18.0f];
    _upvoteCountLabel.font = _followersCountLabel.font = [UIFont fontWithName:kRegularFont size:20.0f];
    _userLabel.font = [UIFont fontWithName:kRegularFont size:24.0f];
    
    _bioTextView.userInteractionEnabled = NO;
    [_tagListView styleForRyff];
    _tagListView.tagDelegate = self;
    
    self.backgroundColor = [RYStyleSheet profileBackgroundColor];
    self.layer.cornerRadius = 10.0f;
    self.clipsToBounds = YES;
}

+ (CGSize) preferredSizeWithAvailableSize:(CGSize)boundingSize forUser:(RYUser *)user
{
    CGFloat heightMinusText = 265.0f;
    CGFloat widthMinusText = 16.0f;
    
    UITextView *sizingTextView        = [[UITextView alloc] init];
    sizingTextView.textContainerInset = UIEdgeInsetsZero;
    sizingTextView.font               = [UIFont fontWithName:kRegularFont size:18.0f];
    sizingTextView.text               = user.bio;
    CGFloat height = [sizingTextView sizeThatFits:CGSizeMake(boundingSize.width-widthMinusText, boundingSize.height)].height;
    
    return CGSizeMake(boundingSize.width, height+heightMinusText);
}

#pragma mark -
#pragma mark - Actions

- (IBAction)followButtonHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(followUserTapped:)])
        [_delegate followUserTapped:_user];
    
    [self styleFollowing:!_user.isFollowing];
}

#pragma mark -
#pragma mark - TagList Delegate

- (void) selectedTag:(NSString *)tagName
{
    if (_delegate && [_delegate respondsToSelector:@selector(tagSelected:)])
        [_delegate tagSelected:tagName];
}

@end
