//
//  UIView+Styling.m
//  Ryff
//
//  Created by Christopher Laganiere on 6/28/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "UIView+Styling.h"

#define kRoundedCornerRadius 10.0f

@implementation UIView (Styling)

- (void) roundTop
{
    // Create the path (with only the top-left corner rounded)
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(kRoundedCornerRadius, kRoundedCornerRadius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the image view's layer
    self.layer.mask = maskLayer;
}

- (void) roundBottom
{
    // Create the path (with only the top-left corner rounded)
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(kRoundedCornerRadius, kRoundedCornerRadius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the image view's layer
    self.layer.mask = maskLayer;
}

@end
