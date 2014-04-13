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

- (RYUser *)initWithUser:(NSInteger)userId username:(NSString *)username firstName:(NSString *)firstName profileImage:(UIImage *)profileImage bio:(NSString*)bio dateCreated:(NSDate *)dateCreated
{
    if (self = [super init])
    {
        _userId         = userId;
        _username       = username;
        _firstName      = firstName;
        _profileImage   = profileImage;
        _bio            = bio;
    }
    return self;
}

// Test User
+(RYUser*)patrick
{
    return [[RYUser alloc] initWithUser:12 username:@"patrickCarney" firstName:@"Patrick" profileImage:[UIImage imageNamed:@"patrickCarney"] bio:@"I'm an American musician best known as the drummer for The Black Keys, a blues rock band from Akron, Ohio. I also have a side-project rock band called Drummer." dateCreated:[NSDate date]];
}
+ (RYUser *)userFromDict:(NSDictionary*)userDict
{
    // id
    NSNumber *user_id = [userDict valueForKey:@"id"];
    
    //username
    NSString *username = [userDict objectForKey:@"username"];
    
    //name
    NSString *name = [userDict objectForKey:@"name"];
    
    // avatar
    NSString *avatarUrl = [userDict objectForKey:@"avatar"];
    
    // bio
    NSString *bio = [userDict objectForKey:@"bio"];
    
    
    // timestamp
    NSString *date_created = [userDict objectForKey:@"date_created"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-DD HH:MM:SS"];
    NSDate *date = [dateFormatter dateFromString:date_created];
    
    RYUser *newUser = [[RYUser alloc] initWithUser:[user_id integerValue] username:username firstName:name profileImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrl]]] bio:bio dateCreated:date];
    return newUser;
}

@end
