//
//  RYTrackDownloadTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 7/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYTrackDownloadTableViewCell.h"

@implementation RYTrackDownloadTableViewCell

- (void) awakeFromNib
{
    [_descriptionLabel setFont:[UIFont fontWithName:kRegularFont size:21.0f]];
    [_descriptionLabel setTextColor:[UIColor whiteColor]];
    [_progressView setBackgroundColor:[UIColor lightGrayColor]];
    [_progressView setTintColor:[UIColor whiteColor]];
}

@end
