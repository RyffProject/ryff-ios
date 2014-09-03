//
//  RYNotification.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNotification.h"

// Data Objects
#import "RYUser.h"
#import "RYNewsfeedPost.h"

@implementation RYNotification

- (id) initWithId:(NSInteger)notifId type:(NotificationType)type isRead:(BOOL)isRead dateUpdated:(NSDate *)dateUpdated
{
    if (self = [super init])
    {
        _notifId     = notifId;
        _type        = type;
        _isRead      = isRead;
        _dateUpdated = dateUpdated;
    }
    return self;
}

+ (RYNotification *)notificationFromDict:(NSDictionary *)notifDict
{
    NSInteger notifId = [notifDict[@"id"] integerValue];
    BOOL isRead       = [notifDict[@"is_read"] boolValue];
    NSString *created = notifDict[@"date_created"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *dateCreated = [dateFormatter dateFromString:created];
    
    NotificationType type = UNRECOGNIZED_NOTIF;
    NSString *typeString = notifDict[@"type"];
    
    if ([typeString isEqualToString:@"follow"])
        type = FOLLOW_NOTIF;
    else if ([typeString isEqualToString:@"upvote"])
        type = UPVOTE_NOTIF;
    else if ([typeString isEqualToString:@"mention"])
        type = MENTION_NOTIF;
    else if ([typeString isEqualToString:@"remix"])
        type = REMIX_NOTIF;
    
    RYNotification *newNotif = [[RYNotification alloc] initWithId:notifId type:type isRead:isRead dateUpdated:dateCreated];
    
    // optional notif data objects
    if (notifDict[@"users"])
        newNotif.users = [RYUser usersFromDictArray:notifDict[@"users"]];
    if (notifDict[@"user"])
        newNotif.user  = [RYUser userFromDict:notifDict[@"user"]];
    if (notifDict[@"posts"])
        newNotif.posts = [RYNewsfeedPost newsfeedPostsFromDictArray:notifDict[@"posts"]];
    if (notifDict[@"post"])
        newNotif.post  = [RYNewsfeedPost newsfeedPostWithDict:notifDict[@"post"]];
    
    return newNotif;
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
