//
//  RYPostsDataSource.h
//  Ryff
//
//  Created by Chris Laganiere on 9/4/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

@import Foundation;

// Data Managers
#import "RYServices.h"

@class RYPost;

@protocol RYPostsDataSourceDelegate <NSObject>
- (void)postUpdatedAtIndex:(NSInteger)postIndex;
- (void)contentUpdated;
- (void)contentFailedToUpdate;
@end

@protocol RYContentFeedDataSource <NSObject>
- (void)fetchContent:(NSInteger)page;
@end

@interface RYPostsDataSource : NSObject <PostDelegate, RYContentFeedDataSource>

@property (nonatomic, weak, nullable) id<RYPostsDataSourceDelegate> delegate;

// Posts

/**
 *  Number of posts available.
 */
- (NSInteger)numberOfPosts;

/**
 *  Retrieves a post at the given index if possible, or nil.
 *
 *  @param postIndex NSInteger index of the requested post.
 *
 *  @return `RYPost` object, or nil.
 */
- (RYPost * __nullable)postAtIndex:(NSInteger)postIndex;

/**
 *  Should load more content in addition to existing content by fetching more posts from 
 *  the server beginning at one past the last page requested.
 */
- (void)loadMoreContent;

/**
 *  Should refresh content by replacing existing content with new posts from the server.
 *  Will fetch posts starting at page 1.
 */
- (void)refreshContent;


// Actions

/**
 *  Toggle starred value on the supplied post.
 *
 *  @param post `RYPost` object to attempt to star.
 */
- (void)toggleStarred:(RYPost * __nullable)post;

@end
