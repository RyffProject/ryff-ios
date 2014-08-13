//
//  RYRiffCreateTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 6/17/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffCreateTableViewCell.h"

// Custom UI
#import "RYStyleSheet.h"

@interface RYRiffCreateTableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *playbackLabel;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIView *playbackSpeedSlider;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

// Data
@property (nonatomic, weak) AVAudioPlayer *audioPlayer;
@property (nonatomic, weak) id<RiffCreateCellDelegate> riffCreateDelegate;

@end

@implementation RYRiffCreateTableViewCell

- (void) configureForAudioPlayer:(AVAudioPlayer*)player forDelegate:(id<RiffCreateCellDelegate>)delegate lastRowInSection:(BOOL)lastRowInSection
{
    _riffCreateDelegate = delegate;
    _audioPlayer        = player;
    
    if (lastRowInSection)
        [_separatorView setBackgroundColor:[UIColor clearColor]];
    else
        [_separatorView setBackgroundColor:[RYStyleSheet backgroundColor]];
    
    [_playButton setTintColor:[RYStyleSheet audioActionColor]];
    [_deleteButton setTintColor:[RYStyleSheet audioActionColor]];
    [_volumeSlider setTintColor:[RYStyleSheet audioActionColor]];
    [_playbackSpeedSlider setTintColor:[RYStyleSheet audioActionColor]];
    
    [_playbackLabel setFont:[UIFont fontWithName:kRegularFont size:14.0f]];
    [_playbackLabel setTextColor:[UIColor whiteColor]];
    [_volumeLabel setFont:[UIFont fontWithName:kRegularFont size:14.0f]];
    [_volumeLabel setTextColor:[UIColor whiteColor]];
    
    [self setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Styling

- (void) stylePlaying
{
    [_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
}

- (void) stylePaused
{
    [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)playButtonHit:(id)sender
{
    if (_riffCreateDelegate && [_riffCreateDelegate respondsToSelector:@selector(playTrack:)])
        [_riffCreateDelegate playTrack:_audioPlayer];
}

- (IBAction)deleteButtonHit:(id)sender
{
    if (_riffCreateDelegate && [_riffCreateDelegate respondsToSelector:@selector(deleteTrack:)])
        [_riffCreateDelegate deleteTrack:_audioPlayer];
}

- (IBAction)volumeSliderChanged:(id)sender
{
    UISlider *volumeSlider = sender;
    if (_riffCreateDelegate && [_riffCreateDelegate respondsToSelector:@selector(changeTrack:volume:)])
        [_riffCreateDelegate changeTrack:_audioPlayer volume:volumeSlider.value];
}

- (IBAction)playbackSpeedSliderChanged:(id)sender
{
    UISlider *playbackSlider = sender;
    if (_riffCreateDelegate && [_riffCreateDelegate respondsToSelector:@selector(changeTrack:playbackSpeed:)])
        [_riffCreateDelegate changeTrack:_audioPlayer playbackSpeed:playbackSlider.value];
}

@end
