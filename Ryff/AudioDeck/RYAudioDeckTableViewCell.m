//
//  RYAudioDeckTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 8/10/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYAudioDeckTableViewCell.h"

// Data Managers
#import "RYStyleSheet.h"
#import "RYAudioDeckManager.h"

// Data Objects
#import "RYNewsfeedPost.h"
#import "RYUser.h"
#import "RYRiff.h"

// Custom UI
#import "RYPlayControl.h"

@interface RYAudioDeckTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *statusWrapperView;
@property (weak, nonatomic) IBOutlet RYPlayControl *playControl;
@property (weak, nonatomic) IBOutlet UILabel *trackIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *riffTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

// Data
@property (nonatomic, strong) RYNewsfeedPost *post;
@property (nonatomic, assign) NSInteger trackIdx;

@end

@implementation RYAudioDeckTableViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [_trackIndexLabel setTextColor:[UIColor whiteColor]];
    [_artistLabel setTextColor:[UIColor whiteColor]];
    [_riffTitleLabel setTextColor:[UIColor whiteColor]];
    [_durationLabel setTextColor:[UIColor whiteColor]];
    [_trackIndexLabel setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    [_artistLabel setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    [_riffTitleLabel setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    [_durationLabel setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    
    [_playControl configureWithFrame:_playControl.frame centerImageInset:nil];
    [_playControl setControlTintColor:[UIColor whiteColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadProgress:) name:kDownloadProgressNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioDeckTrackChanged:) name:kTrackChangedNotification object:nil];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    
    [_playControl setProgress:0.0f animated:NO];
}

- (void) configureForPost:(RYNewsfeedPost *)post trackIdx:(NSInteger)trackIdx
{
    _post = post;
    _trackIdx = trackIdx;
    
    NSString *artistText = (post.user.nickname && post.user.nickname.length > 0) ? post.user.nickname : post.user.username;
    [_artistLabel setText:artistText];
    [_riffTitleLabel setText:post.riff.title];
    [_durationLabel setText:[RYStyleSheet convertSecondsToDisplayTime:post.riff.duration]];
    
    [self styleFromAudioDeck];
    
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void) styleFromAudioDeck
{
    if (_post.postId == [[RYAudioDeckManager sharedInstance] currentlyPlayingPost].postId)
    {
        // currently playing
        [self hidePlaylistIndex:YES];
        [self styleDownloading:NO];
        
        if ([[RYAudioDeckManager sharedInstance] isPlaying])
            [_playControl setCenterImage:[UIImage imageNamed:@"playing"]];
        else
            [_playControl setCenterImage:[UIImage imageNamed:@"play"]];
    }
    else if ([[RYAudioDeckManager sharedInstance] idxOfDownload:_post] >= 0)
    {
        // currently downloading
        [self styleDownloading:YES];
        [_playControl setCenterImage:nil];
    }
    else if (_trackIdx > 0)
    {
        // just in playlist
        [_trackIndexLabel setText:[NSString stringWithFormat:@"%ld",(long)_trackIdx]];
        [self hidePlaylistIndex:NO];
        [_playControl setCenterImage:nil];
        [self styleDownloading:NO];
    }
}

- (void) hidePlaylistIndex:(BOOL)hidePlaylistIndex
{
    if (hidePlaylistIndex)
    {
        [_trackIndexLabel setHidden:YES];
        [_playControl setHidden:NO];
    }
    else
    {
        [_trackIndexLabel setHidden:NO];
        [_playControl setHidden:YES];
    }
}

- (void) styleDownloading:(BOOL)downloading
{
    if (downloading)
    {
        [self hidePlaylistIndex:YES];
        [_artistLabel setAlpha:0.5f];
        [_riffTitleLabel setAlpha:0.5f];
        [_durationLabel setAlpha:0.5f];
        [_playControl setCenterImage:nil];
    }
    else
    {
        [_artistLabel setAlpha:1.0f];
        [_riffTitleLabel setAlpha:1.0f];
        [_durationLabel setAlpha:1.0f];
    }
}

#pragma mark -
#pragma mark - Notifications

- (void) updateDownloadProgress:(NSNotification *)notification
{
    NSDictionary *notifDict = notification.object;
    if (notifDict[@"postID"])
    {
        if ([notifDict[@"postID"] integerValue] == _post.postId && notifDict[@"progress"])
        {
            CGFloat progress = [notifDict[@"progress"] floatValue];
            [_playControl setProgress:progress animated:YES];
        }
    }
}

- (void) audioDeckTrackChanged:(NSNotification *)notification
{
    [self styleFromAudioDeck];
}

@end
