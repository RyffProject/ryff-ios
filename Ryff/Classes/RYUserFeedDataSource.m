//
//  RYUserFeedDataSource.m
//  Ryff
//
//  Created by Chris Laganiere on 9/4/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

#import "RYUserFeedDataSource.h"

@interface RYUserFeedDataSource () <UsersDelegate>

@end

@implementation RYUserFeedDataSource

- (nonnull instancetype)initWithUser:(RYUser * __nonnull)user {
    NSParameterAssert(user);
    if (self = [super init]) {
        _user = user;
    }
    return self;
}

#pragma mark - Private

- (void)fetchContent:(NSInteger)page {
    if (page <= 1) {
        [[RYServices sharedInstance] getUserWithId:@(_user.userId) orUsername:nil delegate:self];
    }
    [[RYServices sharedInstance] getUserPostsForUser:_user.userId page:@(page) delegate:self];
}

#pragma mark - UsersDelegate

- (void)retrievedUsers:(NSArray *)users {
    RYUser *user = users.firstObject;
    if (user) {
        _user = user;
        [self.delegate contentUpdated];
    }
}

@end
