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

// Data Objects
#import "RYNotification.h"

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

@end
