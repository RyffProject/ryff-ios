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

- (void) downloadChanged:(BOOL)finished
{
    if (finished)
    {
        UIImage *maskedImage = [RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"play.png"];
        [_playPauseButton setImage:maskedImage forState:UIControlStateNormal];
    }
    else
    {
        // prepare loading images
        NSInteger numImages = 3;
        NSMutableArray *images = [[NSMutableArray alloc] init];
        
        // load all rotations of these images
        for (NSInteger rotateVar = 0; rotateVar < 4; rotateVar++)
        {
            for (NSInteger imNum = 1; imNum <= numImages; imNum++)
            {
                UIImage *loadingImage = [UIImage imageNamed:[NSString stringWithFormat:@"Loading_%d",imNum]];
                loadingImage = [RYStyleSheet image:loadingImage RotatedByRadians:M_PI_2*rotateVar];
                [images addObject:loadingImage];
            }
        }
        
        // Normal Animation
        _playPauseButton.imageView.animationImages = images;
        _playPauseButton.imageView.animationDuration = 0.5;
        
        [_playPauseButton.imageView startAnimating];
    }
}

@end
