//
//  NSObject+block.m
//  LSATMax
//
//  Created by Jason Loewy on 3/13/13.
//  Copyright (c) 2013 Jason Loewy. All rights reserved.
//

#import "NSObject+block.h"

@implementation NSObject (block)

- (void) performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(fireBlock:) withObject:block afterDelay:delay];
}

- (void) fireBlock:(void (^)(void)) block { block(); }

@end
