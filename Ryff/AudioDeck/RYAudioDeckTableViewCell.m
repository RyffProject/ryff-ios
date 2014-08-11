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

@end

@implementation RYAudioDeckTableViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void) configureForPost:(RYNewsfeedPost *)post trackIdx:(NSInteger)trackIdx
{
    NSString *artistText = (post.user.nickname && post.user.nickname.length > 0) ? post.user.nickname : post.user.username;
    [_artistLabel setText:artistText];
    [_riffTitleLabel setText:post.riff.title];
    [_durationLabel setText:[RYStyleSheet convertSecondsToDisplayTime:post.riff.duration]];
    
    if (trackIdx >= 0)
        [_trackIndexLabel setText:[NSString stringWithFormat:@"%ld",(long)trackIdx]];
    else
        [_trackIndexLabel setText:@""];
    
    [self stylePlaying:NO];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void) stylePlaying:(BOOL)playing
{
    if (playing)
    {
        [_trackIndexLabel setHidden:YES];
        [_playControl setHidden:NO];
        [_playControl animatePlaying];
    }
    else
    {
        [_trackIndexLabel setHidden:NO];
        [_playControl setHidden:YES];
        [_playControl stopPlaying];
    }
}

- (void) styleDownloading:(BOOL)downloading
{
    if (downloading)
    {
        [self stylePlaying:YES];
        [_artistLabel setAlpha:0.5f];
        [_riffTitleLabel setAlpha:0.5f];
        [_durationLabel setAlpha:0.5f];
    }
    else
    {
        [_artistLabel setAlpha:1.0f];
        [_riffTitleLabel setAlpha:1.0f];
        [_durationLabel setAlpha:1.0f];
    }
}

- (void) updateDownloadProgress:(CGFloat)progress
{
    [_playControl animateOuterProgress:progress];
}

@end
