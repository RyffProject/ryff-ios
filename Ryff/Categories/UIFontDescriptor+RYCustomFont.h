//
//  UIFontDescriptor+RYCustomFont.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/19/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFontDescriptor (RYCustomFont)

+ (UIFontDescriptor *)preferredCustomFontDescriptorWithTextStyle:(NSString *)style;
+ (UIFontDescriptor *)preferredCustomBoldFontDescriptorWithTextStyle:(NSString *)style;

@end
