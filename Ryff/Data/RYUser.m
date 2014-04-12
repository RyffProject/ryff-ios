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

- (RYUser *)initWithUsername:(NSString *)username firstName:(NSString *)firstName profileImage:(UIImage *)profileImage bio:(NSString *)bio groups:(NSSet *)groups activity:(NSArray *)activity
{
    if (self = [super init])
    {
        _username       = username;
        _firstName      = firstName;
        _profileImage   = profileImage;
        _bio            = bio;
        _groups         = groups;
        _activity       = activity;
    }
    return self;
}

// Test User
+(RYUser*)patrick
{
    return [[RYUser alloc] initWithUsername:@"patrickCarney" firstName:@"Patrick" profileImage:[UIImage imageNamed:@"patrickCarney"] bio:@"I'm an American musician best known as the drummer for The Black Keys, a blues rock band from Akron, Ohio. I also have a side-project rock band called Drummer." groups:[NSSet set] activity:[RYNewsfeedPost testNewsfeedPosts]];
}

@end
