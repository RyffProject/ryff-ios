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

+(UIColor*)actionColor;
+(UIColor*)actionHighlightedColor;
+(UIColor*)foregroundColor;
+(UIColor*)backgroundColor;

+(UIFont *)fontFamily;
+(UIFont *)regularFont;
+(UIFont *)boldFont;
+(UIFont *)lightFont;
+(UIFont *)italicFont;
+(UIFont *)titleFont;

+(UIImage *) image:(UIImage*)imageToRotate RotatedByRadians:(CGFloat)radians;

+ (NSAttributedString *)createAttributedTextWithPost:(RYNewsfeedPost *)post;

@end
