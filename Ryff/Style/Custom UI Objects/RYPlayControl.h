//
//  RYPlayControl.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

typedef enum : NSUInteger {
    DOWNLOADING,
    PLAYING,
    PAUSED
} PlayControlState;

@interface RYPlayControl : UIView

@property (nonatomic, assign) PlayControlState playControlState;
@property (nonatomic, strong) UIColor *controlTintColor;

- (void) configureWithFrame:(CGRect)frame;
- (void) animateOuterProgress:(CGFloat)progress;
- (void) animateInnerProgress:(CGFloat)progress;
- (void) animatePlaying;
- (void) animateDownloading;
- (void) stopPlaying;

@end
