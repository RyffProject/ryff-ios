//
//  RYUser.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYUser.h"

// Data Objects
#import "RYNewsfeedPost.h"

@implementation RYUser

- (RYUser *)initWithUser:(NSInteger)userId username:(NSString *)username nickname:(NSString *)nickname avatarURL:(NSString*)avatarURL karma:(NSInteger)karma bio:(NSString*)bio dateCreated:(NSDate *)dateCreated genres:(NSSet*)genres instruments:(NSSet*)instruments
{
    if (self = [super init])
    {
        _userId         = userId;
        _username       = username;
        _nickname       = nickname;
        _avatarURL      = avatarURL;
        _karma          = karma;
        _bio            = bio;
        _genres         = genres;
        _instruments    = instruments;
    }
    return self;
}

+ (RYUser *)userFromDict:(NSDictionary*)userDict
{
    NSNumber *userId        = [userDict objectForKey:@"id"];
    NSString *username      = [userDict objectForKey:@"username"];
    NSString *name          = [userDict objectForKey:@"name"];
    NSString *avatarUrl     = [userDict objectForKey:@"avatar"];
    NSNumber *karma         = [userDict objectForKey:@"karma"];
    NSString *bio           = [userDict objectForKey:@"bio"];
    NSString *dateCreated   = [userDict objectForKey:@"date_created"];
    NSDate *date            = [NSDate date];
    
    if (dateCreated)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-DD HH:MM:SS"];
        date = [dateFormatter dateFromString:dateCreated];
    }
    
    RYUser *newUser = [[RYUser alloc] initWithUser:[userId intValue] username:username nickname:name avatarURL:avatarUrl karma:[karma intValue] bio:bio dateCreated:date genres:nil instruments:nil];
    return newUser;
}

@end
