//
//  RYNotificationsTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNotificationsTableViewCell.h"

// Data Managers
#import "RYStyleSheet.h"

// Data Objects
#import "RYNotification.h"

@interface RYNotificationsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@end

@implementation RYNotificationsTableViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [RYStyleSheet styleProfileImageView:_avatarImageView];
    [_topLabel setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    [_bottomLabel setFont:[UIFont fontWithName:kLightFont size:16.0f]];
    [_bottomLabel setTextColor:[RYStyleSheet availableActionColor]];
}

- (void) configureWithNotification:(RYNotification *)notification
{
    [_topLabel setText:@"configured!"];
    
    NSTimeInterval timeSince = [[NSDate date] timeIntervalSinceDate:notification.dateUpdated];
    [_bottomLabel setText:[RYStyleSheet displayTimeWithSeconds:timeSince]];
}

@end
