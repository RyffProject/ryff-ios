//
//  RYRiffCreateTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 6/17/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffCreateTableViewCell.h"

@interface RYRiffCreateTableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIView *playbackSpeedSlider;

@end

@implementation RYRiffCreateTableViewCell

- (IBAction)playButtonHit:(id)sender
{
    if (_riffCreateDelegate && [_riffCreateDelegate respondsToSelector:@selector(playTrack:)])
        [_riffCreateDelegate playTrack:_trackIndex];
}

- (IBAction)editButtonHit:(id)sender
{
    if (_riffCreateDelegate && [_riffCreateDelegate respondsToSelector:@selector(editTrack:)])
        [_riffCreateDelegate editTrack:_trackIndex];
}

- (IBAction)deleteButtonHit:(id)sender
{
    if (_riffCreateDelegate && [_riffCreateDelegate respondsToSelector:@selector(deleteTrack:)])
        [_riffCreateDelegate deleteTrack:_trackIndex];
}

- (IBAction)volumeSliderChanged:(id)sender
{
    UISlider *volumeSlider = sender;
    if (_riffCreateDelegate && [_riffCreateDelegate respondsToSelector:@selector(changeTrack:volume:)])
        [_riffCreateDelegate changeTrack:_trackIndex volume:volumeSlider.value];
}

- (IBAction)playbackSpeedSliderChanged:(id)sender
{
    UISlider *playbackSlider = sender;
    if (_riffCreateDelegate && [_riffCreateDelegate respondsToSelector:@selector(changeTrack:playbackSpeed:)])
        [_riffCreateDelegate changeTrack:_trackIndex playbackSpeed:playbackSlider.value];
}

@end
