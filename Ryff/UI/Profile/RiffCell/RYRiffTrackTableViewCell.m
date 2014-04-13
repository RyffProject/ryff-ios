//
//  RYRiffTrackTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffTrackTableViewCell.h"

// Data Objects
#import "RYRiff.h"

// Custom UI
#import "RYStyleSheet.h"
#import "RMDownloadIndicator.h"
#import "UIImage+Color.h"

@implementation RYRiffTrackTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) awakeFromNib
{
    if (_refreshTimer)
    {
        [_refreshTimer invalidate];
        _refreshTimer = nil;
    }
    
    // Setup timer and duration countdown
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(refreshTimerHit:)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void) configureForRiff:(RYRiff *)riff
{
    [_riffTitleText setText:riff.title];
    _riffDuration = riff.duration;
    _durationCountdown = riff.duration;
    
    [self setLoadingStatus:STOP];
    [self setCurrentStatus:STOP];
    [self updateDurationText];
}

- (void) updateDurationText
{
    NSInteger seconds = (NSInteger)_durationCountdown % 60;
    NSInteger minutes = (NSInteger)_durationCountdown / 60;
    //NSInteger hours = ((NSInteger)riff.length / 3600);
    
    [_riffLengthText setText:[NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds]];
}

#pragma mark -
#pragma mark - Download UI Updates

- (void) startPlaying
{
    // Set up timer
    _durationCountdown = _riffDuration;
    [self keepPlaying];
}

- (void) keepPlaying
{
    [self setLoadingStatus:PLAY];
}

- (void) updateDownloadIndicatorWithBytes:(CGFloat)bytesFinished outOf:(CGFloat)totalBytes
{
    if (bytesFinished <= totalBytes)
        [_downloadIndicator updateWithTotalBytes:totalBytes downloadedBytes:bytesFinished];
}

- (void) finishDownloading:(BOOL)success
{
    [_downloadIndicator removeFromSuperview];
    _downloadIndicator = nil;
    if (success)
        [self startPlaying];
    else
        [self clearAudio];
}

- (void) startDownloading
{
    [self setLoadingStatus:DOWNLOAD];
}

- (void) shouldPause:(BOOL)shouldPause
{
    if (shouldPause)
    {
        [self setLoadingStatus:STOP];
    }
    else
        [self keepPlaying];
}

- (void) clearAudio
{
    [self setLoadingStatus:STOP];
    
    // reset duration text
    _durationCountdown = _riffDuration;
    [self updateDurationText];
}

#pragma mark - 
#pragma mark - Dynamic UI

- (void) stylePlaying
{
    if (_downloadIndicator)
    {
        [_downloadIndicator removeFromSuperview];
        _downloadIndicator = nil;
    }
    
    // prepare loading images
    NSInteger numImages = 3;
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    // load all rotations of these images
    for (NSNumber *rotation in @[@0,@2,@1,@3])
    {
        for (NSInteger imNum = 1; imNum <= numImages; imNum++)
        {
            NSInteger rotateVar = [rotation integerValue];
            UIImage *loadingImage = [[UIImage imageNamed:[NSString stringWithFormat:@"Loading_%d",imNum]] imageWithOverlayColor:[RYStyleSheet baseColor]];
            loadingImage = [RYStyleSheet image:loadingImage RotatedByRadians:M_PI_2*rotateVar];
            [images addObject:loadingImage];
        }
    }
    
    // Normal Animation
    _statusImageView.animationImages = images;
    _statusImageView.animationDuration = 1.5;
    
    [_statusImageView startAnimating];
}
- (void) styleStop
{
    if (_downloadIndicator)
    {
        [_downloadIndicator removeFromSuperview];
        _downloadIndicator = nil;
    }
    UIImage *maskedImage = [[UIImage imageNamed:@"play.png"] imageWithOverlayColor:[RYStyleSheet baseColor]];
    [_statusImageView setImage:maskedImage];
}
- (void) styleDownloading
{
    _downloadIndicator = [[RMDownloadIndicator alloc]initWithFrame:_statusImageView.frame type:kRMFilledIndicator];
    [_downloadIndicator setBackgroundColor:[UIColor clearColor]];
    [_downloadIndicator setFillColor:[RYStyleSheet baseColor]];
    [_downloadIndicator setStrokeColor:[RYStyleSheet baseColor]];
    _downloadIndicator.radiusPercent = 0.45;
    [self.contentView addSubview:_downloadIndicator];
    [_downloadIndicator loadIndicator];
    
    // and hide imageView
    [_statusImageView setImage:nil];
}

#pragma mark -
#pragma mark - Timers

-(void) refreshTimerHit:(NSTimer*)sender
{
    if (_loadingStatus != _currentStatus)
    {
        // change stuff!
        if (_loadingStatus == PLAY)
        {
            [self stylePlaying];
            _currentStatus = _loadingStatus;
        }
        else if (_loadingStatus == STOP)
        {
            [self styleStop];
            _currentStatus = _loadingStatus;
        }
        else if (_loadingStatus == DOWNLOAD)
        {
            [self styleDownloading];
            _currentStatus = _loadingStatus;
        }
        
    }
    
    if (_currentStatus == PLAY)
    {
        if (_durationCountdown > 0)
        {
            _durationCountdown--;
            [self updateDurationText];
        }
        else
        {
            [self setLoadingStatus:STOP];
        }
    }
}

@end
