//
//  RYRiffCreateTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 6/17/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVAudioPlayer;

@protocol RiffCreateCellDelegate <NSObject>

- (void) playTrack:(AVAudioPlayer*)player;
- (void) deleteTrack:(AVAudioPlayer*)player;
- (void) changeTrack:(AVAudioPlayer*)player volume:(CGFloat)newVolume;
- (void) changeTrack:(AVAudioPlayer*)player playbackSpeed:(CGFloat)playbackSpeed;

@end

@interface RYRiffCreateTableViewCell : UITableViewCell

- (void) configureForAudioPlayer:(AVAudioPlayer*)player forDelegate:(id<RiffCreateCellDelegate>)delegate lastRowInSection:(BOOL)lastRowInSection;

- (void) stylePlaying;
- (void) stylePaused;

@end
