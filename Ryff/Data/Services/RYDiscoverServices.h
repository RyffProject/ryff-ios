//
//  RYDiscoverServices.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

// Data Managers
#import "RYServices.h"

// Search Tags
#define kSearchTags                 @"search-tags.php"
#define kSuggestedTagsAction        @"get-tags-suggested.php"
#define kTrendingTagsAction         @"get-tags-trending.php"

// Search Posts
#define kSearchNewPostsAction       @"search-posts-new.php"
#define kSearchTopPostsAction       @"search-posts-top.php"
#define kSearchTrendingPostsAction  @"search-posts-trending.php"

// Search Users
#define kSearchUsersTrending        @"search-users-trending.php"
#define kSearchUsersNearbyAction    @"search-users-nearby.php"

@protocol TagsDelegate <NSObject>
- (void) retrievedTags:(NSArray *)tags;
@optional
- (void) retrievTagsFailed:(NSString *)reason;
@end

@interface RYDiscoverServices : NSObject

+ (RYDiscoverServices *)sharedInstance;

// Search Tags
- (void) searchTagsFor:(NSString *)query delegate:(id<TagsDelegate>)delegate;
- (void) getTrendingTagsForDelegate:(id<TagsDelegate>)delegate;
- (void) getSuggestedTagsForDelegate:(id<TagsDelegate>)delegate;

// Search Posts
- (void) searchForPostsWithTags:(NSArray *)tags searchType:(SearchType)searchType delegate:(id<PostDelegate>)delegate;

@end
