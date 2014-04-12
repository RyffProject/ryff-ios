//
//  RYStyleSheet.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYStyleSheet.h"

@implementation RYStyleSheet

+(UIColor*)baseColor
{
    return [UIColor orangeColor];
}

+(UIFont *)baseFont
{
    return [UIFont systemFontOfSize:17.0f];
}

+(UIFont *)boldFont
{
    return  [UIFont boldSystemFontOfSize:20.0f];
}
+(UIFont *)longFont
{
    return [UIFont systemFontOfSize:13.0f];
}

+(UIImage *) maskWithColor:(UIColor *)color forImageNamed:(NSString *)imageName
{
    return [self maskWithColor:color forImage:[UIImage imageNamed:imageName]];
}

+(UIImage *) maskWithColor:(UIColor *)color forImage:(UIImage*)image
{
    CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    
    if (UIGraphicsBeginImageContextWithOptions) {
        CGFloat imageScale = 1.0f;
        UIGraphicsBeginImageContextWithOptions(image.size, NO, imageScale);
    }
    else {
        UIGraphicsBeginImageContext(image.size);
    }
    
    [image drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *colored = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return colored;
}

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
