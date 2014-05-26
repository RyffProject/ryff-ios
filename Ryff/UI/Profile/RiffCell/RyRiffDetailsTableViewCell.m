//
//  RYRyRiffDetailsTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 5/25/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RyRiffDetailsTableViewCell.h"

@implementation RyRiffDetailsTableViewCell

- (void) awakeFromNib
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void) configure
{
    [self setBackgroundColor:[UIColor clearColor]];
}

@end
