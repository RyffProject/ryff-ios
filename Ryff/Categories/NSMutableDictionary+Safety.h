//
//  NSMutableDictionary+Safety.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/6/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Safety)

- (void)safelySetObject:(id)anObject forKey:(id <NSCopying>)aKey;

@end
