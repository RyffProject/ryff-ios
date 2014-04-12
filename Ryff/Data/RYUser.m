//
//  RYUser.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYUser.h"

@implementation RYUser

- (RYUser *)initWithUsername:(NSString *)username
{
    if (self = [super init])
    {
        _username = username;
    }
    return self;
}

@end
