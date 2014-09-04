//
//  RYNotificationsTableViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYNotification;

@protocol NotificationSelectionDelegate <NSObject>
- (void) notificationSelected:(RYNotification *)notification;
@end

@interface RYNotificationsTableViewController : UITableViewController

- (void) configureWithDelegate:(id<NotificationSelectionDelegate>)delegate;

@end
