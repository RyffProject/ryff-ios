//
//  RYNewsfeedPost.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNewsfeedPost.h"

// Data Objects
#import "RYRiff.h"
#import "RYUser.h"

@implementation RYNewsfeedPost

- (RYNewsfeedPost *)initWithUser:(RYUser *)user mainText:(NSString*)mainText riff:(RYRiff*)riff
{
    if (self = [super init])
    {
        _user       = user;
        _mainText   = mainText;
        _riff       = riff;
    }
    return self;
}

@end
