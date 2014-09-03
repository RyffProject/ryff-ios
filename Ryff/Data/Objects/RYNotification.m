//
//  RYNotification.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNotification.h"

@implementation RYNotification

- (id) initWithId:(NSInteger)notifId type:(NotificationType)type isRead:(BOOL)isRead dateCreated:(NSDate *)dateCreated
{
    if (self = [super init])
    {
        _notifId     = notifId;
        _type        = type;
        _isRead      = isRead;
        _dateCreated = dateCreated;
    }
    return self;
}

+ (RYNotification *)notificationFromDict:(NSDictionary *)notifDict
{
    return [[RYNotification alloc] initWithId:0 type:FOLLOW_NOTIF isRead:YES dateCreated:[NSDate date]];
}

+ (NSArray *)notificationsFromDictArray:(NSArray *)notifDictArray
{
    NSMutableArray *notifications = [[NSMutableArray alloc] initWithCapacity:notifDictArray.count];
    for (NSDictionary *notifDict in notifDictArray)
    {
        RYNotification *newNotif = [RYNotification notificationFromDict:notifDict];
        [notifications addObject:newNotif];
    }
    return notifications;
}

@end
