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
#import "RYPlayControl.h"
#import "RYSocialTextView.h"

// Categories
#import "UIImage+Color.h"

// Frameworks
#import "UIImageView+SGImageCache.h"

@interface RYRiffCell () <UIGestureRecognizerDelegate>

// Main
@property (weak, nonatomic) IBOutlet UIView *wrapperView;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
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

- (void) configureForPost:(RYNewsfeedPost *)post riffIndex:(NSInteger)riffIndex delegate:(id<RiffCellDelegate>)delegate
{
    _riffIndex = riffIndex;
    _delegate  = delegate;
    _post      = post;
    
    [_postLabel setText:post.riff.title];
    
    NSString *usernameText = (post.user.nickname && post.user.nickname.length > 0) ? post.user.nickname : post.user.username;
    [_userLabel setText:usernameText];
    
    [_socialTextView loadAttributedContent:[[NSAttributedString alloc] initWithString:post.content]];
    
    if (post.riff)
        [_durationLabel setText:[RYStyleSheet convertSecondsToDisplayTime:post.riff.duration]];
    
    if (post.imageURL)
    {
        [_avatarImageView setHidden:YES];
        [_postImageView setHidden:NO];
        [_postImageView setImageForURL:post.imageURL.absoluteString placeholder:[UIImage imageNamed:@"user"]];
    }
    else
    {
        [_avatarImageView setHidden:NO];
        [_avatarImageView setImageForURL:post.user.avatarURL.absoluteString placeholder:[UIImage imageNamed:@"user"]];
        [_postImageView setHidden:YES];
    }
    
    UIColor *starredColor   = post.isStarred ? [RYStyleSheet postActionColor] : [RYStyleSheet availableActionColor];
    [_starButton setTintColor:starredColor];
    
    UIColor *upvotedColor  = post.isUpvoted ? [RYStyleSheet postActionColor] : [RYStyleSheet availableActionColor];
    [_upvoteCountLabel setTextColor:upvotedColor];
    [_upvoteImageView setImage:[_upvoteImageView.image colorImage:upvotedColor]];
    
    [_upvoteCountLabel setText:[NSString stringWithFormat:@"%ld",(long)post.upvotes]];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self styleFromAudioDeck];
}

#pragma mark - Internal

- (void) awakeFromNib
{
    [_postLabel setFont:[UIFont fontWithName:kRegularFont size:20.0f]];
    [_postLabel setTextColor:[UIColor whiteColor]];
    [_userLabel setFont:[UIFont fontWithName:kBoldFont size:20.0f]];
    [_userLabel setTextColor:[UIColor whiteColor]];
    [_socialTextView setColorForContentText:[UIColor whiteColor]];
    [_socialTextView setTextContainerInset:UIEdgeInsetsZero];
    
    [RYStyleSheet styleProfileImageView:_avatarImageView];
    
    UITapGestureRecognizer *playControlTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerControlHit:)];
    [_playControlView addGestureRecognizer:playControlTap];
    [_playControlView setBackgroundColor:[UIColor clearColor]];
    
    [_playControlView configureWithFrame:_playControlView.bounds centerImageInset:@(_playControlView.frame.size.width/4)];
    
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(avatarHit:)];
    [_avatarImageView addGestureRecognizer:avatarTap];
    
    UITapGestureRecognizer *usernameTap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(usernameHit:)];
    [_userLabel addGestureRecognizer:usernameTap];
    
    UITapGestureRecognizer *upvoteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(upvoteHit:)];
    [_upvoteWrapperView addGestureRecognizer:upvoteTap];
    
    [_upvoteCountLabel setFont:[UIFont fontWithName:kRegularFont size:21.0f]];
    [_durationLabel setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    [_durationLabel setTextColor:[UIColor whiteColor]];
    
    [_upvoteImageView setImage:[UIImage imageNamed:@"upvote"]];
    
    [_repostButton setTintColor:[RYStyleSheet availableActionColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioDeckPlaylistChanged:) name:kPlaylistChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioDeckTrackChanged:) name:kTrackChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadProgress:) name:kDownloadProgressNotification object:nil];
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    if (highlighted)
    {
        [_wrapperView setBackgroundColor:[UIColor colorWithWhite:0.35 alpha:0.8f]];
    }
    else
    {
        [_wrapperView setBackgroundColor:[UIColor colorWithWhite:0.25 alpha:0.8f]];
    }
}

- (void) styleFromAudioDeck
{
    RYAudioDeckManager *audioManager = [RYAudioDeckManager sharedInstance];
    if (_post.postId == [audioManager currentlyPlayingPost].postId)
    {
        // currently playing
        _playControlView.hidden             = NO;
        _playControlView.controlTintColor   = [UIColor whiteColor];
        _playlistAddButton.tintColor        = [RYStyleSheet postActionColor];
        [_playControlView setProgress:0.0f animated:NO];
        if ([audioManager isPlaying])
            [_playControlView setCenterImage:[UIImage imageNamed:@"playing"]];
        else
            [_playControlView setCenterImage:[UIImage imageNamed:@"play"]];
    }
    else if ([audioManager playlistContainsPost:_post.postId])
    {
        // in playlist or downloading
        _playControlView.hidden = NO;
        _playControlView.controlTintColor = [UIColor whiteColor];
        _playlistAddButton.tintColor        = [RYStyleSheet postActionColor];
        if ([[RYAudioDeckManager sharedInstance] idxOfDownload:_post] >= 0)
        {
            // downloading
            [_playControlView setCenterImage:nil];
        }
        else
        {
            // in playlist
            [_playControlView setCenterImage:[UIImage imageNamed:@"play"]];
            [_playControlView setProgress:0.0f animated:NO];
        }
    }
    else
    {
        _playControlView.hidden = YES;
        _playlistAddButton.tintColor = [RYStyleSheet availableActionColor];
    }
}

#pragma mark -
#pragma mark - Notifications

- (void) audioDeckPlaylistChanged:(NSNotification *)notification
{
    [self styleFromAudioDeck];
}

- (void) audioDeckTrackChanged:(NSNotification *)notification
{
    [self styleFromAudioDeck];
}

- (void) updateDownloadProgress:(NSNotification *)notification
{
    NSDictionary *notifDict = notification.object;
    if (notifDict[@"postID"])
    {
        if ([notifDict[@"postID"] integerValue] == _post.postId && notifDict[@"progress"])
        {
            CGFloat progress = [notifDict[@"progress"] floatValue];
            [_playControlView setProgress:progress animated:YES];
        }
    }
}

#pragma mark -
#pragma mark - Actions
- (IBAction)playlistAddHit:(id)sender
{
    if ([[RYAudioDeckManager sharedInstance] playlistContainsPost:_post.postId])
    {
        // playlist contains already
        [[RYAudioDeckManager sharedInstance] removePostFromPlaylist:_post];
        [_playlistAddButton setTintColor:[RYStyleSheet availableActionColor]];
    }
    else
    {
        // add to playlist
        [[RYAudioDeckManager sharedInstance] addPostToPlaylist:_post];
        [_playlistAddButton setTintColor:[RYStyleSheet postActionColor]];
    }
}

- (IBAction)repostHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(repostAction:)])
        [_delegate repostAction:_riffIndex];
}

- (IBAction)starHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(starAction:)])
        [_delegate starAction:_riffIndex];
    
    [_starButton setTintColor:[RYStyleSheet postActionColor]];
}

#pragma mark - Gestures

- (void) avatarHit:(UITapGestureRecognizer *)tapGesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(avatarAction:)])
        [_delegate avatarAction:_riffIndex];
}

- (void) usernameHit:(UITapGestureRecognizer *)tapGesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(avatarAction:)])
        [_delegate avatarAction:_riffIndex];
}

- (void)upvoteHit:(UITapGestureRecognizer *)tapGesture
{
    UIColor *upvotedColor  = !_post.isUpvoted ? [RYStyleSheet postActionColor] : [RYStyleSheet availableActionColor];
    [_upvoteImageView setImage:[_upvoteImageView.image colorImage:upvotedColor]];
    
    if (_delegate && [_delegate respondsToSelector:@selector(upvoteAction:)])
        [_delegate upvoteAction:_riffIndex];
}

- (void) playerControlHit:(UITapGestureRecognizer *)tapGesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(playerControlAction:)])
        [_delegate playerControlAction:_riffIndex];
}

@end
