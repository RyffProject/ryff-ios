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

@protocol RYPostsDataSourceDelegate <NSObject>
- (void)postUpdatedAtIndex:(NSInteger)postIndex;
- (void)contentUpdated;
- (void)contentFailedToUpdate;
@end

@protocol RYContentFeedDataSource <NSObject>
- (void)fetchContent:(NSInteger)page;
@end

@interface RYPostsDataSource : NSObject <PostDelegate, RYContentFeedDataSource>

@property (nonatomic, readonly) NSArray/*<RYPost>*/ *feedItems;

@property (nonatomic, weak) id<RYPostsDataSourceDelegate> delegate;

- (void)loadMoreContent;
- (void)refreshContent;

@end
