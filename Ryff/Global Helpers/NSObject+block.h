//
//  NSObject+block.h
//  LSATMax
//
//  Created by Jason Loewy on 3/13/13.
//  Copyright (c) 2013 Jason Loewy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (block)

- (void) performBlock:(void (^)(void)) block afterDelay:(NSTimeInterval) delay;

@end
