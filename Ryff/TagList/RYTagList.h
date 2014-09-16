//
//  RYTagList.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

// Data Managers
#import "RYDiscoverServices.h"

@protocol TagListDelegate <NSObject>

- (void) retrievedTags;

@end

typedef enum : NSUInteger {
    TRENDING_LIST = 1,
    SUGGESTED_LIST
} TagListType;

@interface RYTagList : NSObject <TagDelegate>

- (void) retrieveTrendingTags;
- (void) retrieveSuggestedTags;

- (BOOL) isFetching;

@end
