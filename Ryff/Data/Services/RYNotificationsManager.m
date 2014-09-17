//
//  RYNotificationsManager.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNotificationsManager.h"

// Data Managers
#import "RYServices.h"
#import "RYRegistrationServices.h"

// Data Objects
#import "RYNotification.h"
#import "RYPost.h"
#import "RYUser.h"

// Frameworks
#import "AFHTTPRequestOperationManager.h"

@implementation RYNotificationsManager

static RYNotificationsManager *_sharedInstance;
+ (instancetype)sharedInstance
{
    if (_sharedInstance == NULL)
    {
        _sharedInstance = [RYNotificationsManager allocWithZone:NULL];
    }
    return _sharedInstance;
}

#pragma mark -
#pragma mark - Registration

- (void) registerForPushNotifications
{
    // Push Notifications
    // keep ifdefs to allow building on xCode 5
    if ([RYRegistrationServices loggedInUser])
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
            UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
            if (currentSettings.types != (UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound))
            {
                UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound) categories:nil];
                [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            }
        }
        else
        {
            if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound))
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
        }
#else
        if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound))
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
#endif
    }
}

#pragma mark -
#pragma mark - Notifications

- (void) fetchNotificationsForDelegate:(id<NotificationsDelegate>)delegate page:(NSNumber *)page
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:1];
        if (page)
            params[@"page"] = page;
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kGetNotifications];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *responseDict = responseObject;
            if (responseDict[@"success"])
            {
                if (delegate && [delegate respondsToSelector:@selector(notificationsRetrieved:)])
                {
                    NSArray *notifications = [RYNotification notificationsFromDictArray:responseDict[@"notifications"]];
                    [delegate notificationsRetrieved:notifications];
                }
            }
            else if (responseDict[@"error"] && delegate && [delegate respondsToSelector:@selector(failedNotificationsRetrieval:)])
                [delegate failedNotificationsRetrieval:responseDict[@"error"]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (delegate && [delegate respondsToSelector:@selector(failedNotificationsRetrieval:)])
                [delegate failedNotificationsRetrieval:[error localizedDescription]];
        }];
    });
}

- (void) updatePushToken:(NSString *)pushToken
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        NSUUID *identifier = [[UIDevice currentDevice] identifierForVendor];
        NSDictionary *params = @{@"token": pushToken, @"uuid": [identifier UUIDString]};
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kAddPushTokenAction];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *responseDict = responseObject;
            if (responseDict[@"success"]) {
                //                NSLog(@"Add push token: %@", responseDict[@"success"]);
            } else if (responseDict[@"error"]) {
                NSLog(@"Add push token failed: %@", responseDict[@"error"]);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Add push token failed: %@",[error localizedDescription]);
        }];
    });
}

#pragma mark -
#pragma mark - Helpers

+ (NSString *)notificationString:(RYNotification *)notification
{
    NSString *notificationString;
    
    NSMutableString *usersString;
    NSMutableString *postsString;
    NSString *postString;
    
    if (notification.posts)
    {
        RYPost *lastPost = notification.posts.lastObject;
        postsString = [lastPost.title mutableCopy];
        if (notification.posts.count == 2)
            [postsString appendFormat:@" and 1 other riff"];
        else if (notification.users.count > 2)
            [postsString appendString:[NSString stringWithFormat:@" and %ld other riffs",(notification.posts.count-1)]];
    }
    
    if (notification.users)
    {
        RYUser *lastUser = notification.users.lastObject;
        usersString = [lastUser.username mutableCopy];
        if (notification.users.count == 2)
            [usersString appendFormat:@" and 1 other"];
        else if (notification.users.count > 2)
            [usersString appendString:[NSString stringWithFormat:@" and %ld others",(notification.users.count-1)]];
    }
    
    if (notification.post)
    {
        postString = notification.post.title;
    }
    
    switch (notification.type) {
        case FOLLOW_NOTIF:
            notificationString = [NSString stringWithFormat:@"%@ followed you.",usersString];
            break;
        case UPVOTE_NOTIF:
            notificationString = [NSString stringWithFormat:@"%@ upvoted %@",usersString,postString];
            break;
        case REMIX_NOTIF:
            notificationString = [NSString stringWithFormat:@"%@ remixed %@",usersString,postString];
            break;
        case MENTION_NOTIF:
            notificationString = [NSString stringWithFormat:@"You were mentioned in %@",postsString];
            break;
        case UNRECOGNIZED_NOTIF:
            break;
    }
    return notificationString;
}

@end
