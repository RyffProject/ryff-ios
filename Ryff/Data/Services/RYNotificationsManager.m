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
#import "RYStyleSheet.h"

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
    if (!page)
        page = @(1);
    
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        NSDictionary *params = @{@"page": page};
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kGetNotifications];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *responseDict = responseObject;
            if (responseDict[@"success"])
            {
                if (delegate && [delegate respondsToSelector:@selector(notificationsRetrieved:page:)])
                {
                    NSArray *notifications = [RYNotification notificationsFromDictArray:responseDict[@"notifications"]];
                    [delegate notificationsRetrieved:notifications page:page];
                }
            }
            else if (responseDict[@"error"] && delegate && [delegate respondsToSelector:@selector(failedNotificationsRetrieval:page:)])
                [delegate failedNotificationsRetrieval:responseDict[@"error"] page:page];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (delegate && [delegate respondsToSelector:@selector(failedNotificationsRetrieval:page:)])
                [delegate failedNotificationsRetrieval:[error localizedDescription] page:page];
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

/**
 *  Helper method to build an attributed string for the description of this notification. Will be used when displaying table of notifications to the user.
 *
 *  @param notification the notification to use
 *
 *  @return styled attributed string
 */
+ (NSAttributedString *)notificationString:(RYNotification *)notification
{
    NSMutableAttributedString *notificationString;
    
    NSMutableString *usersString;
    NSString *postsString;
    NSString *postString;
    
    if (notification.posts)
    {
        RYPost *lastPost = notification.posts.lastObject;
        postString = [lastPost.title mutableCopy];
        if (notification.posts.count == 2)
            postsString = @" and 1 other riff";
        else if (notification.users.count > 2)
            postsString = [NSString stringWithFormat:@" and %ld other riffs",(notification.posts.count-1)];
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
    
    NSDictionary *notificationTextAttributes = @{NSForegroundColorAttributeName: [UIColor darkTextColor]};
    NSDictionary *highlightedNotificationAttributes = @{NSForegroundColorAttributeName: [RYStyleSheet postActionColor]};
    switch (notification.type) {
        case FOLLOW_NOTIF:
            notificationString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ followed you.",usersString] attributes:notificationTextAttributes];
            break;
        case UPVOTE_NOTIF:
            notificationString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ upvoted ",usersString] attributes:notificationTextAttributes];
            [notificationString appendAttributedString:[[NSAttributedString alloc] initWithString:postString attributes:highlightedNotificationAttributes]];
            break;
        case REMIX_NOTIF:
            notificationString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ remixed ",usersString] attributes:notificationTextAttributes];
            [notificationString appendAttributedString:[[NSAttributedString alloc] initWithString:postString attributes:highlightedNotificationAttributes]];
            break;
        case MENTION_NOTIF:
            notificationString = [[NSMutableAttributedString alloc] initWithString:@"You were mentioned in " attributes:notificationTextAttributes];
            [notificationString appendAttributedString:[[NSAttributedString alloc] initWithString:postString attributes:highlightedNotificationAttributes]];
            if (postsString)
                [notificationString appendAttributedString:[[NSAttributedString alloc] initWithString:postsString attributes:notificationTextAttributes]];
            break;
        case UNRECOGNIZED_NOTIF:
            break;
    }
    
    [notificationString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kRegularFont size:18.0f] range:NSMakeRange(0, notificationString.string.length)];
    return notificationString;
}

@end
