//
//  RYTagList.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYTagList.h"

// Data Managers
#import "RYRegistrationServices.h"

// Data Objects
#import "RYTag.h"
#import "RYUser.h"

@interface RYTagList ()

@property (nonatomic, strong) NSArray *tagList;
@property (nonatomic, assign) TagListType searchType;
@property (nonatomic, assign) BOOL fetching;

@end

@implementation RYTagList

- (id) initWithTagListType:(TagListType)tagListType
{
    if (self = [super init])
    {
        _searchType = tagListType;
    }
    return self;
}

- (NSArray *)list
{
    return _tagList;
}

- (void) fetchData
{
    if (!_fetching)
    {
        if (_searchType == TRENDING_LIST)
            [[RYDiscoverServices sharedInstance] getTrendingTagsForDelegate:self];
        else if (_searchType == SUGGESTED_LIST)
            [[RYDiscoverServices sharedInstance] getSuggestedTagsForDelegate:self];
        else if (_searchType == MY_LIST)
        {
            // use my tags
            [self tagsRetrieved:[RYRegistrationServices loggedInUser].tags];
        }
        else
        {
            // search tags
        }
        _fetching = YES;
    }
}

- (BOOL) isFetching
{
    return _fetching;
}

- (TagListType)listType
{
    return _searchType;
}

- (NSString *)listTitle
{
    NSString *listTitle;
    if (_searchType == TRENDING_LIST)
        listTitle = @"Trending Tags";
    else if (_searchType == SUGGESTED_LIST)
        listTitle = @"Suggested Tags";
    else if (_searchType == MY_LIST)
        listTitle = @"Subscribed Tags";
    return listTitle;
}

#pragma mark -
#pragma mark - Tag Delegate

- (void) tagsRetrieved:(NSArray *)tags
{
    _tagList = tags;
    _fetching = NO;
    
    if (_delegate && [_delegate respondsToSelector:@selector(tagsUpdated)])
        [_delegate tagsUpdated];
}

@end
