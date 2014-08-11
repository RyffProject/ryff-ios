//
//  RYRiffCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 7/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffCell.h"

// Data Objects
#import "RYNewsfeedPost.h"
#import "RYRiff.h"
#import "RYUser.h"

// Data Managers
#import "RYStyleSheet.h"
#import "RYServices.h"

// UI Objects
#import "RYPlayControl.h"

@interface RYRiffCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *wrapperView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet RYPlayControl *playControlView;
@property (weak, nonatomic) IBOutlet UIButton *upvoteButton;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *upvotesLabel;

@end

@implementation RYRiffCell

- (void) awakeFromNib
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerControlHit:)];
    [_playControlView addGestureRecognizer:tapGesture];
    [_playControlView setBackgroundColor:[UIColor clearColor]];
    
    [_repostButton setTintColor:[RYStyleSheet actionColor]];
    [_followButton setTintColor:[RYStyleSheet actionColor]];
    
    [_upvotesLabel setFont:[UIFont fontWithName:kRegularFont size:21.0f]];
    [_userLabel setFont:[UIFont fontWithName:kRegularFont size:24.0f]];
    
    [_playControlView configureWithFrame:_playControlView.bounds];
}

- (void) configureForPost:(RYNewsfeedPost *)post attributedText:(NSAttributedString *)attributedText riffIndex:(NSInteger)riffIndex delegate:(id<RiffCellDelegate>)delegate
{
    _riffIndex = riffIndex;
    _delegate  = delegate;
    
    NSString *userText = (post.user.nickname && post.user.nickname.length > 0) ? post.user.nickname : post.user.username;
    [_userLabel setText:userText];
    [_postLabel setAttributedText:attributedText];
    
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
    
//    if (post.user && (post.user.userId == [RYServices loggedInUser].userId))
//        [_followButton setHidden:YES];
//    else
//    {
//        [_followButton setHidden:NO];
//        if (post.user.isFollowing)
//            [_followButton setTintColor:[RYStyleSheet actionHighlightedColor]];
//        else
//            [_followButton setTintColor:[RYStyleSheet actionColor]];
//    }
    
    [_upvotesLabel setText:[NSString stringWithFormat:@"%ld",(long)post.upvotes]];
    
    [self setBackgroundColor:[UIColor clearColor]];
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

#pragma mark -
#pragma mark - Media

- (void) startDownloading
{
    
}

- (void) updateDownloadIndicatorWithBytes:(CGFloat)bytesFinished outOf:(CGFloat)totalBytes
{
    CGFloat progress = bytesFinished / totalBytes;
    [_playControlView animateOuterProgress:progress];
}

- (void) finishDownloading:(BOOL)success
{
    if (success)
    {
        [_playControlView animateOuterProgress:1.0f];
        [_playControlView animatePlaying];
    }
    else
    {
        [_playControlView animateOuterProgress:0.0f];
    }
}

- (void) shouldPause:(BOOL)shouldPause
{
    if (shouldPause)
        [_playControlView stopPlaying];
    else
        [_playControlView animatePlaying];
}

- (void) updateTimeRemaining:(CGFloat)playProgress
{
    [_playControlView animateInnerProgress:playProgress];
}

- (void) clearAudio
{
    [_playControlView stopPlaying];
    [_playControlView animateInnerProgress:0.0f];
    [_playControlView animateOuterProgress:0.0f];
}

@end
