//
//  RYRiffCellBodyTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 5/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffCellBodyTableViewCell.h"

// Custom UI
#import "RYStyleSheet.h"

@implementation RYRiffCellBodyTableViewCell

- (void) awakeFromNib
{
    [_backgroundImageView setImage:[self riffCellBottomBackgroundImage]];
    [_backgroundImageView setBounds:_wrapperView.bounds];
    [_riffTextLabel setFont:[RYStyleSheet regularFont]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void) configureWithAttributedString:(NSAttributedString*)attributedString
{
    [_riffTextLabel setAttributedText:attributedString];
    [self setBackgroundColor:[UIColor clearColor]];
}

#pragma mark -
#pragma mark - Cell Utilities

- (UIImage *)riffCellBottomBackgroundImage
{
    UIImage *background;
    float currentVersion = 6.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion)
    {
        //device have iOS 6 or above
        background = [[UIImage imageNamed:@"cellBody.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)  resizingMode:UIImageResizingModeStretch];
    }else{
        //device have iOS 5.1 or belove
        background = [[UIImage imageNamed: @"cellBody.png"] stretchableImageWithLeftCapWidth:15.0 topCapHeight:15.0];
    }
    return background;
}

@end
