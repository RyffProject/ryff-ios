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

@protocol TagDelegate <NSObject>
- (void) tagsRetrieved:(NSArray *)tags;
@optional
- (void) tagsFailedToRetrieve:(NSString *)reason;
@end

@interface RYDiscoverServices : NSObject

+ (RYDiscoverServices *)sharedInstance;

// Search Tags
- (void) searchTagsFor:(NSString *)query delegate:(id<TagDelegate>)delegate;
- (void) getTrendingTagsForDelegate:(id<TagDelegate>)delegate;
- (void) getSuggestedTagsForDelegate:(id<TagDelegate>)delegate;

// Search Posts
- (void) searchForPostsWithTags:(NSArray *)tags searchType:(SearchType)searchType delegate:(id<PostDelegate>)delegate;

@end
