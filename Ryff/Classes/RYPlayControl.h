//
//  RYPlayControl.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

@interface RYPlayControl : UIView

@property (nonatomic, strong, nullable) UIColor *controlTintColor;
@property (nonatomic, strong, nullable) UIImage *centerImage;
@property (nonatomic) CGFloat centerImageInset;
@property (nonatomic) CGFloat strokeWidth;

- (nonnull instancetype)initWithFrame:(CGRect)frame;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

- (void)hideProgress:(BOOL)hideProgress;
- (void)hideCenterImage:(BOOL)hideCenterImage;

@end
