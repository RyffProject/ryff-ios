//
//  RYPostsDataSource.m
//  Ryff
//
//  Created by Chris Laganiere on 9/4/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

#import "RYPostsDataSource.h"

@interface RYPostsDataSource () <RYPostDelegate>

@property (nonatomic) NSArray/*<RYPost>*/ *feedItems;

// Last page of content loaded. Should load next page if fetching more content.
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation RYPostsDataSource

- (instancetype)init {
    if (self = [super init]) {
        _feedItems = @[];
    }
    return self;
}

- (NSInteger)numberOfPosts {
    return self.feedItems.count;
}

- (RYPost * __nullable)postAtIndex:(NSInteger)postIndex {
    if (postIndex >= 0 && postIndex < self.feedItems.count) {
        return self.feedItems[postIndex];
    }
    return nil;
}

- (void)loadMoreContent {
    [self fetchContent:(_currentPage + 1)];
}

- (void)refreshContent {
    [self fetchContent:1];
}

#pragma mark - Actions

- (void)toggleStarred:(RYPost * __nullable)post {
    [post toggleStarred];
}

#pragma mark - Post Delegate

- (void)postSucceeded:(NSArray *)posts page:(NSNumber *)page {
    BOOL shouldClearOldPosts = (!page || page.integerValue <= 1);
    [self addPosts:posts clearOldPosts:shouldClearOldPosts];
    
    _currentPage = page.integerValue;
    [_delegate contentUpdated];
}

- (void)postFailed:(NSString *)reason page:(NSNumber *)page {
    [_delegate contentFailedToUpdate];
}

#pragma mark - RYPostDelegate

- (void)postUpdated:(RYPost *)post {
    [self reloadPost:post];
}

- (void)postUpdateFailed:(RYPost *)post reason:(NSString *)reason {
    NSLog(@"Failed to upvote post #%ld: %@", post.postId, reason);
    if ([self.feedItems containsObject:post]) {
        [self.delegate postUpdatedAtIndex:[self.feedItems indexOfObject:post]];
    }
}

#pragma mark - Private

/**
 *  Start tracking posts by adding them to self.feedItems. Will set delegate on all posts to self.
 *
 *  @param posts NSArray of `RYPost` objects.
 *  @param clearOldPosts Should delete old posts to refresh content, instead of just adding to existing content.
 */
- (void)addPosts:(NSArray *)posts clearOldPosts:(BOOL)clearOldPosts {
    for (RYPost *post in posts) {
        post.delegate = self;
    }
    
    if (clearOldPosts) {
        self.feedItems = posts;
    }
    else {
        self.feedItems = [self.feedItems arrayByAddingObjectsFromArray:posts];
    }
}

/**
 *  Fetch `RYPost` content from server from the given page offset.
 *  Should be implemented by subclasses. Calling this method on `RYPostsDataSource` is undefined.
 *
 *  @param page Page offset from start.
 */
- (void)fetchContent:(NSInteger)page {
    NSAssert(NO, @"Must subclass RYPostsDataSource to specify appropriate fetch action");
}

/**
 *  Search through self.feedItems and try to find an old post with the same postId as the supplied post.
 *  If found, replace with the updated post and notify self.delegate that the post changed.
 *
 *  @param post `RYPost` to attempt to reload.
 */
- (void)reloadPost:(RYPost *)post
{
    for (NSInteger postIndex = 0; postIndex < self.feedItems.count; postIndex++)
    {
        RYPost *oldPost = self.feedItems[postIndex];
        if (oldPost.postId == post.postId)
        {
            // Found the old post, should replace it.
            post.delegate = self;
            NSMutableArray *mutableFeedItems = [self.feedItems mutableCopy];
            [mutableFeedItems replaceObjectAtIndex:postIndex withObject:post];
            _feedItems = mutableFeedItems;
            
            // Notify delegate.
            [self.delegate postUpdatedAtIndex:postIndex];
        }
    }
}
@end
