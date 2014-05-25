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

@interface RYRiffTrackTableViewCell ()

@property (nonatomic, assign) enum LoadingStatus currentStatus;

@end

@implementation RYRiffTrackTableViewCell

- (void) awakeFromNib
{
    [_riffTitleText setFont:[RYStyleSheet regularFont]];
    [_riffLengthText setFont:[RYStyleSheet lightFont]];
    [self setBackgroundColor:[UIColor clearColor]];
    [_backgroundImageView setImage:[self riffCellTopBackgroundImage]];
    [_backgroundImageView setFrame:_wrapperView.bounds];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void) configureForRiff:(RYRiff *)riff
{
    [_riffTitleText setText:riff.title];
    _riffDuration = riff.duration;
    
    [self setCurrentStatus:STOP];
    [self resetDurationText];
}

- (void) updateTimeRemaining:(NSInteger)secondsRemaining
{
    NSInteger seconds = secondsRemaining % 60;
    NSInteger minutes = secondsRemaining / 60;
    //NSInteger hours = ((NSInteger)riff.length / 3600);
    
    [_riffLengthText setText:[NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds]];
}

- (void) resetDurationText
{
    NSInteger seconds = (NSInteger)_riffDuration % 60;
    NSInteger minutes = (NSInteger)_riffDuration / 60;
    //NSInteger hours = ((NSInteger)riff.length / 3600);
    
    [_riffLengthText setText:[NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds]];
}

#pragma mark -
#pragma mark - State Changes

- (void) changeCellToState:(NSInteger)loadingStatus
{
    // change status
    if (_currentStatus != loadingStatus)
    {
        if (loadingStatus == STOP)
        {
            [self resetDurationText];
            [self styleStop];
        }
        else if (loadingStatus == PLAY)
        {
            [self stylePlaying];
        }
        else if (loadingStatus == PAUSE)
        {
            [self styleStop];
        }
        else if (loadingStatus == DOWNLOAD)
        {
            [self styleDownloading];
        }
        _currentStatus = loadingStatus;
    }
}
#pragma mark -
#pragma mark - Download UI Updates

- (void) startPlaying
{
    // Set up timer
    [self changeCellToState:PLAY];
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
    [self changeCellToState:DOWNLOAD];
}

- (void) shouldPause:(BOOL)shouldPause
{
    if (shouldPause)
    {
        [self changeCellToState:PAUSE];
    }
    else
        [self changeCellToState:PLAY];
}

- (void) clearAudio
{
    [self changeCellToState:STOP];
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
            UIImage *loadingImage = [[UIImage imageNamed:[NSString stringWithFormat:@"Loading_%ld",(long)imNum]] imageWithOverlayColor:[RYStyleSheet baseColor]];
            loadingImage = [RYStyleSheet image:loadingImage RotatedByRadians:M_PI_2*rotateVar];
            [images addObject:loadingImage];
        }
    }
    
    // Normal Animation
    [_statusImageView setImage:nil];
    [_statusImageView setAnimationImages:nil];
    [_statusImageView setAnimationImages:images];
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
    [_statusImageView setImage:nil];
    [_statusImageView setAnimationImages:nil];
    UIImage *maskedImage = [[UIImage imageNamed:@"play.png"] imageWithOverlayColor:[RYStyleSheet baseColor]];
    [_statusImageView setImage:maskedImage];
}
- (void) styleDownloading
{
    _downloadIndicator = [[RMDownloadIndicator alloc] initWithFrame:_statusImageView.frame type:kRMFilledIndicator];
    [_downloadIndicator setBackgroundColor:[UIColor clearColor]];
    [_downloadIndicator setFillColor:[RYStyleSheet baseColor]];
    [_downloadIndicator setStrokeColor:[RYStyleSheet baseColor]];
    _downloadIndicator.radiusPercent = 0.45;
    [self.contentView addSubview:_downloadIndicator];
    [_downloadIndicator loadIndicator];
    
    // and hide imageView
    [_statusImageView setImage:nil];
    [_statusImageView setAnimationImages:nil];
}

#pragma mark -
#pragma mark - Cell Utilities
#pragma mark -
#pragma mark - Riff Cell

/*
 Create the background image for a riff uitableviewcell
 */
- (UIImage *)riffCellTopBackgroundImage
{
    UIImage *background;
    float currentVersion = 6.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion)
    {
        //device have iOS 6 or above
        background = [[UIImage imageNamed:@"riffCellBack.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)  resizingMode:UIImageResizingModeStretch];
    }else{
        //device have iOS 5.1 or belove
        background = [[UIImage imageNamed: @"riffCellBack.png"] stretchableImageWithLeftCapWidth:15.0 topCapHeight:15.0];
    }
    return background;
}

@end
