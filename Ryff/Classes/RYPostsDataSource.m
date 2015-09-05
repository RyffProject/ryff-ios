//
//  RYPostsDataSource.m
//  Ryff
//
//  Created by Chris Laganiere on 9/4/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

#import "RYPostsDataSource.h"

@interface RYPostsDataSource ()

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

- (void)loadMoreContent {
    [self fetchContent:(_currentPage + 1)];
}

- (void)refreshContent {
    [self fetchContent:1];
}

#pragma mark - Private

- (void)fetchContent:(NSInteger)page {
    NSAssert(NO, @"Must subclass RYPostsDataSource to specify appropriate fetch action");
}

#pragma mark -
#pragma mark - Post Delegate

- (void)postSucceeded:(NSArray *)posts page:(NSNumber *)page {
    if (page && page.integerValue > 1) {
        self.feedItems = [self.feedItems arrayByAddingObjectsFromArray:posts];
    }
    else {
        self.feedItems = posts;
    }
    _currentPage = page.integerValue;
    [_delegate contentUpdated];
}

- (void)postFailed:(NSString *)reason page:(NSNumber *)page {
    [_delegate contentFailedToUpdate];
}

@end
