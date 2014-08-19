//
//  RYStyleSheet.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RYNewsfeedPost;

@interface RYStyleSheet : NSObject

+ (UIColor *)audioActionColor;
+ (UIColor *)audioActionHighlightedColor;
+ (UIColor *)postActionColor;
+ (UIColor *)postActionHighlightedColor;
+ (UIColor *)tabBarColor;
+ (UIColor *)audioBackgroundColor;
+ (UIColor *)lightBackgroundColor;

+ (UIImage *) image:(UIImage*)imageToRotate RotatedByRadians:(CGFloat)radians;
+ (void) styleProfileImageView:(UIView *)view;

+ (NSAttributedString *)createNewsfeedAttributedTextWithPost:(RYNewsfeedPost *)post;
+ (NSAttributedString *)createProfileAttributedTextWithPost:(RYNewsfeedPost *)post;

+ (NSString *)convertSecondsToDisplayTime:(CGFloat)totalSeconds;

@end
