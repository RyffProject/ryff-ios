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
#import "RYAudioDeckManager.h"
#import "RYServices.h"

// Custom UI
#import "UIImage+Color.h"
#import "RYPlayControl.h"

// Frameworks
#import "UIImageView+SGImageCache.h"

@interface RYRiffCell () <UIGestureRecognizerDelegate>

// Main
@property (weak, nonatomic) IBOutlet UIView *wrapperView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

// Media
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

// PlayControl
@property (weak, nonatomic) IBOutlet RYPlayControl *playControlView;

// Upvote
@property (weak, nonatomic) IBOutlet UIView *upvoteWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *upvoteImageView;
@property (weak, nonatomic) IBOutlet UILabel *upvoteCountLabel;

// Bottom Actions
@property (weak, nonatomic) IBOutlet UIView *actionWrapperView;
@property (weak, nonatomic) IBOutlet UIButton *playlistAddButton;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UIButton *starButton;

// Data
@property (nonatomic, strong) RYNewsfeedPost *post;
@property (nonatomic, strong) NSAttributedString *attributedPostString;

@end

@implementation RYRiffCell

- (void) awakeFromNib
{
    [_userLabel setFont:[UIFont fontWithName:kRegularFont size:24.0f]];
    [_textView setFont:[UIFont fontWithName:kRegularFont size:24.0f]];
    [_avatarImageView.layer setCornerRadius:10.0f];
    [_avatarImageView setClipsToBounds:YES];
    
    [_postImageView.layer setCornerRadius:10.0f];
    [_postImageView setClipsToBounds:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerControlHit:)];
    [_playControlView addGestureRecognizer:tapGesture];
    [_playControlView setBackgroundColor:[UIColor clearColor]];
    
    [_upvoteCountLabel setFont:[UIFont fontWithName:kRegularFont size:21.0f]];
    [_durationLabel setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    
    [_upvoteImageView setImage:[UIImage imageNamed:@"upvote"]];
    
    [_repostButton setTintColor:[RYStyleSheet audioActionColor]];
    
    [_playControlView configureWithFrame:_playControlView.bounds];
}

- (void) configureForPost:(RYNewsfeedPost *)post attributedText:(NSAttributedString *)attributedText riffIndex:(NSInteger)riffIndex delegate:(id<RiffCellDelegate>)delegate
{
    _riffIndex = riffIndex;
    _delegate  = delegate;
    _post      = post;
    
    NSString *usernameText = (post.user.nickname && post.user.nickname.length > 0) ? post.user.nickname : post.user.username;
    [_userLabel setText:usernameText];
    [_textView setAttributedText:attributedText];
    [_textView sizeToFit];
    [_avatarImageView setImageForURL:post.user.avatarURL placeholder:[UIImage imageNamed:@"user"]];
    
    if (post.riff)
        [_durationLabel setText:[RYStyleSheet convertSecondsToDisplayTime:post.riff.duration]];
    
    if (post.imageURL)
    {
        [_postImageView setHidden:NO];
        [_postImageView setImageForURL:post.imageURL.path placeholder:[UIImage imageNamed:@"user"]];
    }
    else
    {
        [_postImageView setHidden:YES];
    }
    
    BOOL inPlaylist         = [[RYAudioDeckManager sharedInstance] playlistContainsPost:post.postId];
    UIColor *playlistColor  = inPlaylist ? [RYStyleSheet audioActionColor] : [RYStyleSheet audioActionHighlightedColor];
    [_playlistAddButton setTintColor:playlistColor];
    
#warning future use
//    BOOL starred            = post.isStarred;
//    UIColor *starredColor   = starred ? [RYStyleSheet audioActionColor] : [RYStyleSheet audioActionHighlightedColor];
//    [_starButton setTintColor:starredColor];
    
    UIColor *upvotedColor  = post.isUpvoted ? [RYStyleSheet audioActionColor] : [RYStyleSheet audioActionHighlightedColor];
    [_upvoteCountLabel setTextColor:upvotedColor];
    [_upvoteImageView setImage:[_upvoteImageView.image colorImage:upvotedColor]];
    
    [_upvoteCountLabel setText:[NSString stringWithFormat:@"%ld",(long)post.upvotes]];
    
    [self setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Internal

#pragma mark -
#pragma mark - Actions
- (IBAction)playlistAddHit:(id)sender
{
    [[RYAudioDeckManager sharedInstance] addPostToPlaylist:_post];
    [_playlistAddButton setTintColor:[RYStyleSheet postActionHighlightedColor]];
}

- (IBAction)repostHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(repostAction:)])
        [_delegate repostAction:_riffIndex];
}

- (IBAction)starHit:(id)sender
{
    
}

#pragma mark - Gestures

- (void)upvoteHit:(UITapGestureRecognizer *)tapGesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(upvoteAction:)])
        [_delegate upvoteAction:_riffIndex];
}

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
