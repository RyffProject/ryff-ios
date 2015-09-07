//
//  NSDictionary+Safety.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/6/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

#import "NSDictionary+Safety.h"

@implementation NSDictionary (Safety)

- (id)safeObjectForKey:(id <NSCopying>)aKey {
    if (aKey && [self objectForKey:aKey] != [NSNull null]) {
        return [self objectForKey:aKey];
    }
    return nil;
}

@end
