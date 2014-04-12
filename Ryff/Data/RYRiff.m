//
//  RYRiff.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiff.h"

@implementation RYRiff

- (RYRiff*)initWithTitle:(NSString*)title length:(NSTimeInterval)length url:(NSString*)url
{
    if (self = [super init])
    {
        _title  = title;
        _length = length;
        _URL    = url;
    }
    return self;
}

@end
