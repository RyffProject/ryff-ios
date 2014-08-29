//
//  RYLoginTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 6/28/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYLoginTableViewCell.h"

// Custom UI
#import "RYStyleSheet.h"

// Categories
#import "UIView+Styling.h"

@implementation RYLoginTableViewCell

- (void) configureWithTitle:(NSString*)title
{
    [_loginLabel setFont:[UIFont fontWithName:kBoldFont size:24.0f]];
    [_loginLabel setText:title];
    [self.contentView roundBottom];
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted)
        [self.contentView setBackgroundColor:[RYStyleSheet availableActionColor]];
    else
        [self.contentView setBackgroundColor:[RYStyleSheet audioActionColor]];
}

@end
