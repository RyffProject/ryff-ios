//
//  RYStyleSheet.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYStyleSheet.h"

// Data Objects
#import "RYNewsfeedPost.h"
#import "RYRiff.h"
#import "RYUser.h"

// Categories
#import "UIColor+Hex.h"

@implementation RYStyleSheet

+ (UIColor *)audioActionColor
{
    return [UIColor colorWithHexString:@"fe9900"];
}

+ (UIColor *)audioActionHighlightedColor
{
    return [UIColor colorWithHexString:@"fed100"];
}

+ (UIColor *)postActionColor
{
    return [UIColor colorWithHexString:@"fff"];
}

+ (UIColor *)postActionHighlightedColor
{
    return [UIColor colorWithHexString:@"fff"];
}

+ (UIColor*)foregroundColor
{
    return [UIColor colorWithHexString:@"383838"];
}

+ (UIColor*)backgroundColor
{
    return [UIColor colorWithHexString:@"00a7d1"];
}

+ (UIFont *)fontFamily
{
    return [UIFont fontWithName:@"Lato" size:18.0f];
}

+ (UIFont *)regularFont
{
    return [UIFont fontWithName:@"Lato-Regular" size:18.0f];
}

+ (UIFont *)boldFont
{
    return [UIFont fontWithName:@"Lato-Bold" size:18.0f];
}

+ (UIFont *)lightFont
{
    return [UIFont fontWithName:@"Lato-Light" size:18.0f];
}

+ (UIFont *)italicFont
{
    return [UIFont fontWithName:@"Lato-Italic" size:18.0f];
}

+ (UIFont*)titleFont
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

#pragma mark -
#pragma mark - Extras

// Username: post content
+ (NSAttributedString *)createNewsfeedAttributedTextWithPost:(RYNewsfeedPost *)post
{
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [RYStyleSheet boldFont], NSFontAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              [RYStyleSheet regularFont], NSFontAttributeName, nil];
    const NSRange range = NSMakeRange(0,post.user.username.length);
    
    // Create the attributed string (text + attributes)
    NSString *fullText = [NSString stringWithFormat:@"%@\n%@",post.user.username,post.content];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText
                                                                                       attributes:subAttrs];
    [attributedText setAttributes:attrs range:range];
    return attributedText;
}

// post title: post content
+ (NSAttributedString *)createProfileAttributedTextWithPost:(RYNewsfeedPost *)post
{
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [RYStyleSheet boldFont], NSFontAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              [RYStyleSheet regularFont], NSFontAttributeName, nil];
    const NSRange range = NSMakeRange(0,post.riff.title.length);
    
    // Create the attributed string (text + attributes)
    NSString *fullText = [NSString stringWithFormat:@"%@\n%@",post.riff.title,post.content];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText
                                                                                       attributes:subAttrs];
    [attributedText setAttributes:attrs range:range];
    return attributedText;
}

+ (NSString *)convertSecondsToDisplayTime:(CGFloat)totalSeconds
{
    NSInteger hours = (totalSeconds / 3600);
    totalSeconds -= (hours * 3600);
    
    NSInteger minutes = (totalSeconds / 60);
    NSInteger seconds = (totalSeconds - (minutes * 60));
    
    NSString* displayTime;
    if (hours > 0)
        displayTime = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    else if (hours == 0)
        displayTime = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    
    return displayTime;
}

@end
