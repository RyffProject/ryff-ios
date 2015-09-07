//
//  NSMutableDictionary+Safety.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/6/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

#import "NSMutableDictionary+Safety.h"

@implementation NSMutableDictionary (Safety)

- (void)safelySetObject:(id)anObject forKey:(id <NSCopying>)aKey {
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
}

@end
