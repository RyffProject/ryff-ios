//
//  RYStyleSheet.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RYStyleSheet : NSObject

// Colors
+ (UIColor *)audioActionColor;
+ (UIColor *)availableActionColor;
+ (UIColor *)postActionColor;
+ (UIColor *)tabBarColor;
+ (UIColor *)audioBackgroundColor;
+ (UIColor *)lightBackgroundColor;
+ (UIColor *)darkBackgroundColor;
+ (UIColor *)profileBackgroundColor;
+ (UIColor *)darkTextColor;

// Fonts
+ (UIFont *)customFontForTextStyle:(NSString *)textStyle;
+ (UIFont *)boldCustomFontForTextStyle:(NSString *)textStyle;

// Image Utilities
+ (UIImage *) image:(UIImage*)imageToRotate RotatedByRadians:(CGFloat)radians;
+ (void) styleProfileImageView:(UIView *)view;

// Extras
+ (NSString *)convertSecondsToDisplayTime:(CGFloat)totalSeconds;
+ (NSString *)displayTimeWithSeconds:(CGFloat)totalSeconds;

@end
