//
//  RYNotificationsTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYNotification;

@interface RYNotificationsTableViewCell : UITableViewCell

- (void) configureWithNotification:(RYNotification *)notification;

@end
