//
//  UIImage+Size.m
//  Ryff
//
//  Created by Chris Laganiere on 9/5/2015
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

#import "UIImage+Size.h"

@implementation UIImage (Size)

-(UIImage *) imageWithSize:(CGSize)size
{
    CGSize mainImageSize = self.size;
    
    UIImage *thumb;
    
    CGFloat widthScaler = size.width / mainImageSize.width;
    CGFloat heightScaler = size.height / mainImageSize.height;
    
    CGSize repositionedMainImageSize = mainImageSize;
    
    CGFloat scaleFactor;
    // Determine if we should shrink based on width or hight
    if(widthScaler < heightScaler)
    {
        // calculate based on width scaler
        scaleFactor = widthScaler;
        repositionedMainImageSize.height = ceil(size.height / scaleFactor);
    }
    else {
        // calculate based on height scaler
        scaleFactor = heightScaler;
        repositionedMainImageSize.width = ceil(size.width / heightScaler);
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGFloat xInc = ((repositionedMainImageSize.width-mainImageSize.width) / 2.f) *scaleFactor;
    CGFloat yInc = ((repositionedMainImageSize.height-mainImageSize.height) / 2.f) *scaleFactor;
    
    [self drawInRect:CGRectMake(xInc, yInc, mainImageSize.width * scaleFactor, mainImageSize.height * scaleFactor)];
    thumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumb;
}

@end
