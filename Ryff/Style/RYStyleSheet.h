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

+(UIFont*)baseFont;
+(UIFont*)boldFont;
+(UIFont*)longFont;

+(UIImage *) image:(UIImage*)imageToRotate RotatedByRadians:(CGFloat)radians;

@end
