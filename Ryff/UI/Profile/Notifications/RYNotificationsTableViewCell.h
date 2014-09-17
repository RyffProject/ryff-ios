//
//  RYNotificationsTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNotificationsCellHeightMinusText 29.0f
#define kNotificationsCellWidthMinusText 78.0f
#define kNotificationsCellFont [UIFont fontWithName:kRegularFont size:18.0f]

@class RYNotification;

@interface RYNotificationsTableViewCell : UITableViewCell

- (void) configureWithNotification:(RYNotification *)notification;

@end
