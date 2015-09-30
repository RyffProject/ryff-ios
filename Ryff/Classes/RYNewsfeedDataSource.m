//
//  RYNewsfeedDataSource.m
//  Ryff
//
//  Created by Chris Laganiere on 9/4/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

#import "RYNewsfeedDataSource.h"

@implementation RYNewsfeedDataSource

- (void)fetchContent:(NSInteger)page {
    [[RYServices sharedInstance] getNewsfeedPostsWithPage:@(page) delegate:self];
}

@end
