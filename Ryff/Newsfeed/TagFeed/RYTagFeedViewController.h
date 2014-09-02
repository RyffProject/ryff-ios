//
//  RYTagFeedViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/1/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNewsfeedTableViewController.h"

@interface RYTagFeedViewController : RYNewsfeedTableViewController

- (void) configureWithTags:(NSArray *)tags;

@end
