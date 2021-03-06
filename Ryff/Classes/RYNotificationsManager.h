//
//  RYNotificationsManager.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAddPushTokenAction     @"add-apns-token.php"
#define kGetNotifications       @"get-notifications.php"
#define kGetOneNotification     @"get-notification.php"

@class RYNotification;

@protocol NotificationsDelegate <NSObject>
- (void) notificationsRetrieved:(NSArray *)notifications page:(NSNumber *)page;
@optional
- (void) failedNotificationsRetrieval:(NSString *)reason page:(NSNumber *)page;
@end

@interface RYNotificationsManager : NSObject

+ (instancetype)sharedInstance;

// Registration
- (void) registerForPushNotifications;

// Notifications
- (void) fetchNotificationsForDelegate:(id<NotificationsDelegate>)delegate page:(NSNumber *)page;

- (void) updatePushToken:(NSString *)pushToken;

// Helpers
+ (NSAttributedString *)notificationString:(RYNotification *)notification;

@end
