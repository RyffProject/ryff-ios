//
//  RYNotification.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RYUser;
@class RYPost;

typedef enum : NSUInteger {
    UNRECOGNIZED_NOTIF = 0,
    FOLLOW_NOTIF,
    UPVOTE_NOTIF,
    MENTION_NOTIF,
    REMIX_NOTIF
} NotificationType;

@interface RYNotification : NSObject

@property (nonatomic, assign) NSInteger notifId;
@property (nonatomic, assign) NotificationType type;
@property (nonatomic, assign) BOOL isRead;
@property (nonatomic, strong) NSDate *dateUpdated;

// Optional
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) RYUser *user;
@property (nonatomic, strong) RYPost *post;

- (id) initWithId:(NSInteger)notifId type:(NotificationType)type isRead:(BOOL)isRead dateUpdated:(NSDate *)dateUpdated;

+ (RYNotification *)notificationFromDict:(NSDictionary *)notifDict;
+ (NSArray *)notificationsFromDictArray:(NSArray *)notifDictArray;

@end
