//
//  RYRiffCreateTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 6/17/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RiffCreateCellDelegate <NSObject>

- (void) playTrack:(NSInteger)trackIndex;
- (void) editTrack:(NSInteger)trackIndex;
- (void) deleteTrack:(NSInteger)trackIndex;
- (void) changeTrack:(NSInteger)trackIndex volume:(CGFloat)newVolume;
- (void) changeTrack:(NSInteger)trackIndex playbackSpeed:(CGFloat)playbackSpeed;

@end

@interface RYRiffCreateTableViewCell : UITableViewCell

@property (nonatomic, weak) id<RiffCreateCellDelegate> riffCreateDelegate;
@property (nonatomic, assign) NSInteger trackIndex;

@end
