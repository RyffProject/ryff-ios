//
//  RYTagList.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYTagList.h"

// Data Objects
#import "RYTag.h"

@interface RYTagList ()

@property (nonatomic, strong) NSArray *tagList;
@property (nonatomic, assign) TagListType searchType;
@property (nonatomic, assign) BOOL fetching;

@end

@implementation RYTagList

- (void) retrieveTrendingTags
{
    if (!_fetching)
    {
        _searchType = TRENDING_LIST;
        [[RYDiscoverServices sharedInstance] getTrendingTagsForDelegate:self];
        _fetching = YES;
    }
}

- (void) retrieveSuggestedTags
{
    if (!_fetching)
    {
        _searchType = SUGGESTED_LIST;
        [[RYDiscoverServices sharedInstance] getSuggestedTagsForDelegate:self];
        _fetching = YES;
    }
}

- (BOOL) isFetching
{
    return _fetching;
}

#pragma mark -
#pragma mark - Tag Delegate

- (void) tagsRetrieved:(NSArray *)tags
{
    _tagList = tags;
    _fetching = NO;
}

@end
