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
- (void) tagsUpdated;
@end

typedef enum : NSUInteger {
    SEARCH = 0,
    TRENDING_LIST,
    SUGGESTED_LIST
} TagListType;

@interface RYTagList : NSObject <TagDelegate>

@property (nonatomic, weak) id<TagListDelegate> delegate;

- (id) initWithTagListType:(TagListType)tagListType;

- (NSArray *)list;

- (void) fetchData;
- (BOOL) isFetching;
- (TagListType)listType;
- (NSString *)listTitle;

@end
