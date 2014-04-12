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
    
    NSInteger seconds = (NSInteger)riff.length % 60;
    NSInteger minutes = (NSInteger)riff.length % 60;
    //NSInteger hours = ((NSInteger)riff.length / 3600);
    [_riffLengthText setText:[NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds]];
}

#pragma mark -
#pragma mark - Download UI Updates

- (void) startPlaying
{
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

- (void) updateDownloadIndicatorWithBytes:(CGFloat)bytesFinished outOf:(CGFloat)totalBytes
{
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
    }
    else
        [self startPlaying];
}

- (void) clearAudio
{
    [_downloadIndicator removeFromSuperview];
    _downloadIndicator = nil;
    
    UIImage *maskedImage = [RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"play.png"];
    [_statusImageView setImage:maskedImage];
}


@end
