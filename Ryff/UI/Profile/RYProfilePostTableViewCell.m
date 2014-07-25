//
//  RYProfileTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 7/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYProfilePostTableViewCell.h"

// Data Objects
#import "RYNewsfeedPost.h"
#import "RYRiff.h"
#import "RYUser.h"

// Data Managers
#import "RYStyleSheet.h"
#import "RYServices.h"

@interface RYProfilePostTableViewCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *wrapperView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UIView *playerControlView;
@property (weak, nonatomic) IBOutlet UIButton *upvoteButton;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *upvotesLabel;

@end

@implementation RYProfilePostTableViewCell

- (void) awakeFromNib
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerControlHit:)];
    [_playerControlView addGestureRecognizer:tapGesture];
    [_playerControlView setBackgroundColor:[UIColor clearColor]];
    
    [_repostButton setTintColor:[RYStyleSheet actionColor]];
    [_followButton setTintColor:[RYStyleSheet actionColor]];
    
    [_upvotesLabel setFont:[UIFont fontWithName:kRegularFont size:21.0f]];
    [_userLabel setFont:[UIFont fontWithName:kRegularFont size:24.0f]];
    [_postLabel setFont:kProfileCellPostFont];
}

- (void) configureForPost:(RYNewsfeedPost *)post riffIndex:(NSInteger)riffIndex delegate:(id<ProfilePostCellDelegate>)delegate
{
    _riffIndex = riffIndex;
    _delegate  = delegate;
    
    NSString *userText = (post.user.nickname && post.user.nickname.length > 0) ? post.user.nickname : post.user.username;
    [_userLabel setText:userText];
    
    if (post.isUpvoted)
    {
        [_upvoteButton setTintColor:[RYStyleSheet actionHighlightedColor]];
        [_upvotesLabel setTextColor:[RYStyleSheet actionHighlightedColor]];
    }
    else
    {
        [_upvoteButton setTintColor:[RYStyleSheet actionColor]];
        [_upvotesLabel setTextColor:[RYStyleSheet actionColor]];
    }
    
    if (post.user && (post.user.userId == [RYServices loggedInUser].userId))
        [_followButton setHidden:YES];
    else
        [_followButton setHidden:NO];
    
    [_upvotesLabel setText:[NSString stringWithFormat:@"%ld",(long)post.upvotes]];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)upvoteHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(upvoteAction:)])
        [_delegate upvoteAction:_riffIndex];
}

- (IBAction)repostHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(repostAction:)])
        [_delegate repostAction:_riffIndex];
}

- (IBAction)followHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(followAction:)])
        [_delegate followAction:_riffIndex];
}

#pragma mark - Gestures

- (void) playerControlHit:(UITapGestureRecognizer *)tapGesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(playerControlAction:)])
        [_delegate playerControlAction:_riffIndex];
}

@end
