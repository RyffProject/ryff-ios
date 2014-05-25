//
//  RYStyleSheet.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYStyleSheet.h"

#import "UIColor+Hex.h"

@implementation RYStyleSheet

+(UIColor*)baseColor
{
    return [UIColor colorWithHexString:@"ffc800"];
}
+(UIColor*)backgroundColor
{
    return [UIColor colorWithHexString:@"565b6e"];
}

+(UIFont *)fontFamily
{
    return [UIFont fontWithName:@"Lato" size:18.0f];
}

+(UIFont *)regularFont
{
    return [UIFont fontWithName:@"Lato-Regular" size:18.0f];
}

+(UIFont *)boldFont
{
    return [UIFont fontWithName:@"Lato-Bold" size:18.0f];
}

+(UIFont *)lightFont
{
    return [UIFont fontWithName:@"Lato-Light" size:18.0f];
}

+(UIFont *)italicFont
{
    return [UIFont fontWithName:@"Lato-Italic" size:18.0f];
}

+(UIFont*)titleFont
{
    return [UIFont fontWithName:@"Lato-Bold" size:20.0f];
}

#pragma mark -
#pragma mark - Image Utilities

+ (UIImage *)image:(UIImage*)imageToRotate RotatedByRadians:(CGFloat)radians
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,imageToRotate.size.width, imageToRotate.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, radians);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-imageToRotate.size.width / 2, -imageToRotate.size.height / 2, imageToRotate.size.width, imageToRotate.size.height), [imageToRotate CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
