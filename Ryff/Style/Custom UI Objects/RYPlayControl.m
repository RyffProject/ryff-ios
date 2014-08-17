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

#define kAnimationDuration 1.5f

@interface RYPlayControl ()

@property (nonatomic, strong) CAShapeLayer *circleShape;
@property (nonatomic, strong) CAShapeLayer *innerCircleShape;
@property (nonatomic, strong) UIImageView *centerImageView;

// Data
@property (nonatomic, strong) NSTimer *rotationAnimationTimer;

@end

@implementation RYPlayControl

- (void) configureWithFrame:(CGRect)frame
{
    if (!_controlTintColor)
        _controlTintColor = [RYStyleSheet audioActionColor];
    
    CGFloat outerStrokeWidth = 3.0f;
    CGFloat innerStrokeWidth = 6.0f;
    
    _circleShape      = [CAShapeLayer layer];
    CGPoint circleCenter        = CGPointMake(frame.size.width/2, frame.size.height/2);
    _circleShape.path           = [UIBezierPath bezierPathWithArcCenter:circleCenter radius:(frame.size.width-outerStrokeWidth/2) / 2 startAngle:-M_PI_2 endAngle:-M_PI_2 + 2 * M_PI clockwise:YES].CGPath;
    _circleShape.strokeColor    = _controlTintColor.CGColor;
    _circleShape.fillColor      = nil;
    _circleShape.lineWidth      = outerStrokeWidth;
    _circleShape.strokeEnd      = 0.0f;
    [self.layer addSublayer:_circleShape];
    
    
    _innerCircleShape                = [CAShapeLayer layer];
    _innerCircleShape.path           = [UIBezierPath bezierPathWithArcCenter:circleCenter radius:(frame.size.width-innerStrokeWidth-outerStrokeWidth) / 2 startAngle:-M_PI_2 endAngle:-M_PI_2 + 2 * M_PI clockwise:YES].CGPath;
    _innerCircleShape.strokeColor    = _controlTintColor.CGColor;
    _innerCircleShape.fillColor      = nil;
    _innerCircleShape.lineWidth      = innerStrokeWidth;
    _innerCircleShape.strokeEnd      = 0.0f;
    _innerCircleShape.anchorPoint    = (CGPoint){0.5, 0.5};
    _innerCircleShape.bounds         = frame;
    _innerCircleShape.position       = circleCenter;
    [self.layer addSublayer:_innerCircleShape];
    
    CGFloat strokeWidth = 1.5*(outerStrokeWidth + innerStrokeWidth);
    CGRect imageFrame   = CGRectMake(strokeWidth, strokeWidth, frame.size.width-2*strokeWidth, frame.size.height-2*strokeWidth);
    _centerImageView    = [[UIImageView alloc] initWithFrame:imageFrame];
    [self addSubview:_centerImageView];
    [self styleCenterImagePlaying:NO];
}

#pragma mark - 
#pragma mark - Animations

- (void) animateOuterProgress:(CGFloat)progress
{
    [self animateFill:_circleShape toStrokeEnd:progress];
}

- (void) animateInnerProgress:(CGFloat)progress
{
    [self animateFill:_innerCircleShape toStrokeEnd:progress];
}

- (void) animateDownloading
{
    if (_playControlState != DOWNLOADING)
    {
        [self stopPlaying];
        [_centerImageView setImage:nil];
        _innerCircleShape.strokeColor = _controlTintColor.CGColor;
        _circleShape.strokeColor = _controlTintColor.CGColor;
        
        _playControlState = DOWNLOADING;
    }
}

- (void) animatePlaying
{
    if (_playControlState != PLAYING)
    {
        [self animateOuterProgress:0.0f];
        
        [self styleCenterImagePlaying:YES];
        [self doRotation];
        [_rotationAnimationTimer invalidate];
        _rotationAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:kAnimationDuration target:self selector:@selector(rotationAnimationTimerTick:) userInfo:nil repeats:YES];
    }
}

- (void) stopPlaying
{
    if (_playControlState != PAUSED)
    {
        [self animateOuterProgress:0.0f];
        
        [_rotationAnimationTimer invalidate];
        [_innerCircleShape removeAnimationForKey:@"transform.rotation"];
        [self styleCenterImagePlaying:NO];
    }
}

#pragma mark - Internal

/**
 Style the center image with either a play or pause icon, depending on current state (playing = YES -> style for currently playing)
 */
- (void) styleCenterImagePlaying:(BOOL)playing
{
    if (playing)
    {
        _playControlState = PLAYING;
        [_centerImageView setImage:[[UIImage imageNamed:@"playing"] colorImage:_controlTintColor]];
    }
    else
    {
        _playControlState = PAUSED;
        [_centerImageView setImage:[[UIImage imageNamed:@"play"] colorImage:_controlTintColor]];
    }
}

- (void) rotationAnimationTimerTick:(NSTimer*)timer
{
    [self doRotation];
}

- (void) doRotation
{
    [self animateRotate:_innerCircleShape toRotationEnd:2*M_PI withDuration:kAnimationDuration];
}

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

- (void) animateRotate:(CAShapeLayer*)shapeLayer toRotationEnd:(CGFloat)rotationEnd withDuration:(CGFloat)animationDuration
{
    [shapeLayer removeAnimationForKey:@"transform.rotation"];
    
    NSNumber *rotationAtStart = [shapeLayer valueForKeyPath:@"transform.rotation"];
    CATransform3D myRotationTransform = CATransform3DRotate(shapeLayer.transform, rotationEnd, 0.0, 0.0, 1.0);
    shapeLayer.transform = myRotationTransform;
    CABasicAnimation *myAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    myAnimation.duration = animationDuration;
    myAnimation.fromValue = rotationAtStart;
    myAnimation.toValue = [NSNumber numberWithFloat:([rotationAtStart floatValue] + rotationEnd)];
    [shapeLayer addAnimation:myAnimation forKey:@"transform.rotation"];
}

@end
