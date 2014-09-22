//
//  RYUser.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYUser.h"

// Data Objects
#import "RYPost.h"
#import "RYTag.h"

@implementation RYUser

- (RYUser *)initWithUser:(NSInteger)userId username:(NSString *)username nickname:(NSString *)nickname karma:(NSInteger)karma bio:(NSString*)bio dateCreated:(NSDate *)dateCreated isFollowing:(BOOL)isFollowing numFollowers:(NSInteger)numFollowers numFollowing:(NSInteger)numFollowing tags:(NSArray *)tags
{
    if (self = [super init])
    {
        _userId         = userId;
        _username       = username;
        _nickname       = nickname;
        _karma          = karma;
        _bio            = bio;
        _isFollowing    = isFollowing;
        _numFollowers   = numFollowers;
        _numFollowing   = numFollowing;
        _tags           = tags;
    }
    return self;
}

+ (RYUser *)userFromDict:(NSDictionary*)userDict
{
    NSNumber *userId        = [userDict objectForKey:@"id"];
    NSString *username      = [userDict objectForKey:@"username"];
    NSString *name          = [userDict objectForKey:@"name"];
    NSNumber *karma         = [userDict objectForKey:@"karma"];
    NSString *bio           = [userDict objectForKey:@"bio"];
    NSString *dateCreated   = [userDict objectForKey:@"date_created"];
    BOOL isFollowing        = [[userDict objectForKey:@"is_following"] boolValue];
    NSInteger numFollowers  = [[userDict objectForKey:@"num_followers"] intValue];
    NSInteger numFollowing  = [[userDict objectForKey:@"num_following"] intValue];
    NSArray *tags           = [RYTag tagsFromDictArray:[userDict objectForKey:@"tags"]];
    
    NSDate *date;
    if (dateCreated)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        date = [dateFormatter dateFromString:dateCreated];
    }
    
    RYUser *newUser = [[RYUser alloc] initWithUser:userId.intValue username:username nickname:name karma:karma.intValue bio:bio dateCreated:date isFollowing:isFollowing numFollowers:numFollowers numFollowing:numFollowing tags:tags];
    
    if (userDict[@"avatar_url"] && [userDict[@"avatar_url"] length] > 0)
        newUser.avatarURL = [NSURL URLWithString:userDict[@"avatar_url"]];
    if (userDict[@"avatar_small_url"] && [userDict[@"avatar_small_url"] length] > 0)
        newUser.avatarSmallURL = [NSURL URLWithString:userDict[@"avatar_small_url"]];
    
    
    return newUser;
}

+ (NSArray *) usersFromDictArray:(NSArray *)dictArray
{
    NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:dictArray.count];
    for (NSDictionary *userDict in dictArray)
    {
        RYUser *newUser = [RYUser userFromDict:userDict];
        [users addObject:newUser];
    }
    return users;
}

-(id)copyWithZone:(NSZone *)zone
{
    // We'll ignore the zone for now
    RYUser *newUser = [[RYUser alloc] initWithUser:self.userId username:self.username nickname:self.nickname karma:self.karma bio:self.bio dateCreated:self.dateCreated isFollowing:self.isFollowing numFollowers:self.numFollowers numFollowing:self.numFollowing tags:self.tags];
    newUser.avatarURL = _avatarURL;
    newUser.avatarSmallURL = _avatarSmallURL;
    return newUser;
}

@end
