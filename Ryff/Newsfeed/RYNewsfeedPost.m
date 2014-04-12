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

- (RYNewsfeedPost *)initWithUsername:(NSString *)username mainText:(NSString*)mainText riff:(RYRiff*)riff
{
    if (self = [super init])
    {
        _username   = username;
        _mainText   = mainText;
        _riff       = riff;
    }
    return self;
}

@end
