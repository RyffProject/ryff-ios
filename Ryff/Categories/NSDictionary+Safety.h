//
//  NSDictionary+Safety.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/6/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Safety)

- (id)safeObjectForKey:(id <NSCopying>)aKey;

@end
