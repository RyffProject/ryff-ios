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

@implementation RYRiffTrackTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureForRiff:(RYRiff *)riff
{
    [_riffTitleText setText:riff.title];
    _riffDuration = riff.length;
    _durationCountdown = riff.length;
    
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
    
    // Setup timer and duration countdown
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(refreshTimerHit:)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void) keepPlaying
{
    // Setup timer and duration countdown
    [self setPaused:NO];
    // Update image
    [self setShouldBePlaying:YES];
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

- (void) shouldPause:(BOOL)shouldPause
{
    if (shouldPause)
    {
        UIImage *maskedImage = [RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"play.png"];
        [_statusImageView setImage:maskedImage];
        [_durationTimer invalidate];
        _durationTimer = nil;
    }
    else
        [self keepPlaying];
    _paused = shouldPause;
}

- (void) clearAudio
{
    [_downloadIndicator removeFromSuperview];
    _downloadIndicator = nil;
    
    // reset duration text
    [_durationTimer invalidate];
    _durationTimer = nil;
    _durationCountdown = _riffDuration;
    [self updateDurationText];
    [self setShouldBePlaying:NO];
}

#pragma mark -
#pragma mark - Timers

-(void) refreshTimerHit:(NSTimer*)sender
{
    if (!_downloadIndicator && _playing && !_shouldBePlaying)
    {
        // stop animation
        UIImage *maskedImage = [RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"play.png"];
        [_statusImageView setImage:maskedImage];
    }
    if (!_downloadIndicator && !_playing && _shouldBePlaying)
    {
        //start animation
        
        // prepare loading images
        NSInteger numImages = 3;
        NSMutableArray *images = [[NSMutableArray alloc] init];
        
        // load all rotations of these images
        for (NSNumber *rotation in @[@0,@2,@1,@3])
        {
            for (NSInteger imNum = 1; imNum <= numImages; imNum++)
            {
                NSInteger rotateVar = [rotation integerValue];
                UIImage *loadingImage = [RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:[NSString stringWithFormat:@"Loading_%d",imNum]];
                loadingImage = [RYStyleSheet image:loadingImage RotatedByRadians:M_PI_2*rotateVar];
                [images addObject:loadingImage];
            }
        }
        
        // Normal Animation
        _statusImageView.animationImages = images;
        _statusImageView.animationDuration = 1.5;
        
        [_statusImageView startAnimating];
    }
    
    if (!_paused)
    {
        if (_durationCountdown > 0)
        {
            _durationCountdown--;
            [self updateDurationText];
        }
        else
        {
            _paused = YES;
        }
    }
}

@end
