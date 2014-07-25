//
//  RYPlayControl.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

@interface RYPlayControl : UIView

- (void) configureWithFrame:(CGRect)frame;
- (void) animateOuterProgress:(CGFloat)progress;
- (void) animateInnerProgress:(CGFloat)progress;
- (void) animatePlaying;

@end
