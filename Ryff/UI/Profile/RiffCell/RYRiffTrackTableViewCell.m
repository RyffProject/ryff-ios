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
    
    UIImage *maskedImage = [RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"play.png"];
    [_playPauseButton setImage:maskedImage forState:UIControlStateNormal];
}

@end
