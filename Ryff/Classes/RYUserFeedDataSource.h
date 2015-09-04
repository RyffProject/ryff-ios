//
//  RYUserFeedDataSource.h
//  Ryff
//
//  Created by Chris Laganiere on 9/4/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

#import "RYPostsDataSource.h"

@class RYUser;

@interface RYUserFeedDataSource : RYPostsDataSource

@property (nonatomic, readonly, nonnull) RYUser *user;

- (nonnull instancetype)initWithUser:(RYUser * __nonnull)user NS_DESIGNATED_INITIALIZER;

@end
