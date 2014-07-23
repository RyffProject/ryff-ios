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

@interface RYRiffCellBodyTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<RYRiffDetailsCellDelegate> delegate;
@property (nonatomic, assign) NSInteger riffIndex;

@end

@implementation RYRiffCellBodyTableViewCell

- (void) awakeFromNib
{
    [_backgroundImageView setImage:[self riffCellBottomBackgroundImage]];
    [_backgroundImageView setBounds:_wrapperView.bounds];
    [_riffTextLabel setFont:[RYStyleSheet regularFont]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longPress];
}

- (void) configureWithAttributedString:(NSAttributedString*)attributedString index:(NSInteger)riffIndex delegate:(id<RYRiffDetailsCellDelegate>)delegate
{
    [_riffTextLabel setAttributedText:attributedString];
    [self setBackgroundColor:[UIColor clearColor]];
    _riffIndex = riffIndex;
    _delegate  = delegate;
}

#pragma mark - Actions

- (void) longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // only call on gesture start
        if (_delegate && [_delegate respondsToSelector:@selector(longPress:)])
            [_delegate longPress:_riffIndex];
    }
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
