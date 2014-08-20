//
//  RYPlayControl.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

@interface RYPlayControl : UIView

@property (nonatomic, strong) UIColor *controlTintColor;

- (void) configureWithFrame:(CGRect)frame;
- (void) setProgress:(CGFloat)progress animated:(BOOL)animated;
- (void) setCenterImage:(UIImage *)image;

@end
