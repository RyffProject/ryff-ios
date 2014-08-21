//
//  RYPlayControl.m
//  Ryff
//
//  Created by Christopher Laganiere on 7/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "RYPlayControl.h"

// Custom UI
#import "RYStyleSheet.h"
#import "UIImage+Color.h"

@interface RYPlayControl ()

@property (nonatomic, strong) CAShapeLayer *circleShape;
@property (nonatomic, strong) UIImageView *centerImageView;

@end

@implementation RYPlayControl

- (void) configureWithFrame:(CGRect)frame centerImageInset:(NSNumber *)centerImageInset
{
    if (!_controlTintColor)
        _controlTintColor = [RYStyleSheet audioActionColor];
    
    CGFloat outerStrokeWidth = 3.0f;
    
    _circleShape      = [CAShapeLayer layer];
    CGPoint circleCenter        = CGPointMake(frame.size.width/2, frame.size.height/2);
    _circleShape.path           = [UIBezierPath bezierPathWithArcCenter:circleCenter radius:(frame.size.width-outerStrokeWidth/2) / 2 startAngle:-M_PI_2 endAngle:-M_PI_2 + 2 * M_PI clockwise:YES].CGPath;
    _circleShape.strokeColor    = _controlTintColor.CGColor;
    _circleShape.fillColor      = nil;
    _circleShape.lineWidth      = outerStrokeWidth;
    _circleShape.strokeEnd      = 0.0f;
    [self.layer addSublayer:_circleShape];
    
    CGFloat inset = centerImageInset ? centerImageInset.floatValue : 2*outerStrokeWidth;
    CGRect imageFrame   = CGRectMake(inset, inset, frame.size.width-2*inset, frame.size.height-2*inset);
    _centerImageView    = [[UIImageView alloc] initWithFrame:imageFrame];
    _centerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_centerImageView];
}

- (void) setControlTintColor:(UIColor *)controlTintColor
{
    _controlTintColor = controlTintColor;
    [_centerImageView setImage:[_centerImageView.image colorImage:_controlTintColor]];
    _circleShape.strokeColor      = _controlTintColor.CGColor;
}

- (void) setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (animated)
        [self animateFill:_circleShape toStrokeEnd:progress];
    else
    {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.0];
        _circleShape.strokeEnd = progress;
        [CATransaction commit];
    }
}

- (void) setCenterImage:(UIImage *)image
{
    if (image)
        [_centerImageView setImage:[image colorImage:_controlTintColor]];
    else
        [_centerImageView setImage:nil];
}

#pragma mark - Internal

- (void) animateFill:(CAShapeLayer*)shapeLayer toStrokeEnd:(CGFloat)strokeEnd
{
    [shapeLayer removeAnimationForKey:@"strokeEnd"];
    
    CGFloat animationDuration = 0.1f;
    
    CABasicAnimation *fillStroke = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    fillStroke.duration          = animationDuration;
    fillStroke.fromValue         = @(shapeLayer.strokeEnd);
    fillStroke.toValue           = @(strokeEnd);
    shapeLayer.strokeEnd         = strokeEnd;
    [shapeLayer addAnimation:fillStroke forKey:@"fill stroke"];
}

@end
