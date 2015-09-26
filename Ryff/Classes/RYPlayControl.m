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

@property (nonatomic, strong) NSArray *configuredSubviewConstraints;

@end

@implementation RYPlayControl

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _controlTintColor = [RYStyleSheet audioActionColor];
        _centerImageInset = 5.0f;
        _strokeWidth = 3.0f;
        
        _centerImageView    = [[UIImageView alloc] initWithFrame:CGRectZero];
        _centerImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_centerImageView];
        
        _configuredSubviewConstraints = [self subviewConstraints];
        [NSLayoutConstraint activateConstraints:self.configuredSubviewConstraints];
        
        _circleShape = [self progressCircleWithFrame:self.frame strokeWidth:self.strokeWidth color:self.controlTintColor];
        [self.layer addSublayer:self.circleShape];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    if (animated) {
        [self animateFill:_circleShape toStrokeEnd:progress];
    }
    else {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.0];
        self.circleShape.strokeEnd = progress;
        [CATransaction commit];
    }
}

#pragma mark - Visibility

- (void)hideProgress:(BOOL)hideProgress {
    self.circleShape.hidden = YES;
}

- (void)hideCenterImage:(BOOL)hideCenterImage {
    self.centerImageView.hidden = hideCenterImage;
}

#pragma mark - Properties

- (void)setCenterImage:(UIImage * __nullable)centerImage {
    [_centerImageView setImage:[centerImage colorImage:self.controlTintColor]];
}

- (void)setControlTintColor:(UIColor * __nullable)controlTintColor {
    _controlTintColor = controlTintColor ?: [UIColor blueColor];
    [self.centerImageView setImage:[self.centerImageView.image colorImage:self.controlTintColor]];
    _circleShape.strokeColor = self.controlTintColor.CGColor;
}

- (void)setCenterImageInset:(CGFloat)centerImageInset {
    _centerImageInset = centerImageInset;
    [self resetConstraints];
}

#pragma mark - Internal

- (CAShapeLayer *)progressCircleWithFrame:(CGRect)frame strokeWidth:(CGFloat)strokeWidth color:(UIColor *)color {
    CAShapeLayer *circleShape  = [CAShapeLayer layer];
    CGPoint circleCenter       = CGPointMake(frame.size.width/2, frame.size.height/2);
    circleShape.path           = [UIBezierPath bezierPathWithArcCenter:circleCenter radius:(frame.size.width-strokeWidth/2) / 2 startAngle:-M_PI_2 endAngle:-M_PI_2 + 2 * M_PI clockwise:YES].CGPath;
    circleShape.strokeColor    = color.CGColor;
    circleShape.fillColor      = nil;
    circleShape.lineWidth      = strokeWidth;
    circleShape.strokeEnd      = 0.0f;
    return circleShape;
}

- (void)animateFill:(CAShapeLayer*)shapeLayer toStrokeEnd:(CGFloat)strokeEnd {
    [shapeLayer removeAnimationForKey:@"strokeEnd"];
    
    CGFloat animationDuration = 0.1f;
    
    CABasicAnimation *fillStroke = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    fillStroke.duration          = animationDuration;
    fillStroke.fromValue         = @(shapeLayer.strokeEnd);
    fillStroke.toValue           = @(strokeEnd);
    shapeLayer.strokeEnd         = strokeEnd;
    [shapeLayer addAnimation:fillStroke forKey:@"fill stroke"];
}

- (void)resetConstraints {
    [NSLayoutConstraint deactivateConstraints:self.configuredSubviewConstraints];
    _configuredSubviewConstraints = [self subviewConstraints];
    [NSLayoutConstraint activateConstraints:self.configuredSubviewConstraints];
}

#pragma mark - Layout

- (NSArray *)subviewConstraints {
    NSDictionary *views = @{@"image": self.centerImageView};
    NSDictionary *metrics = @{@"inset": @(self.centerImageInset)};
    NSMutableArray *constraints = [[NSMutableArray alloc] initWithCapacity:16];
    
    // Center image view
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(inset)-[image]-(inset)-|" options:0 metrics:metrics views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(inset)-[image]-(inset)-|" options:0 metrics:metrics views:views]];
    
    return @[];
}

@end
