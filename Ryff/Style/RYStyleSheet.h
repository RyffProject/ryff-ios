//
//  RYStyleSheet.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RYStyleSheet : NSObject

+(UIColor*)baseColor;
+(UIColor*)backgroundColor;

+(UIFont*)baseFont;
+(UIFont*)boldFont;
+(UIFont*)longFont;
+(UIFont*)titleFont;

+(UIImage *) image:(UIImage*)imageToRotate RotatedByRadians:(CGFloat)radians;

@end
