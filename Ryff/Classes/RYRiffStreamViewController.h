//
//  RYRiffStreamViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/6/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffStreamingCoreViewController.h"

@interface RYRiffStreamViewController : RYRiffStreamingCoreViewController

- (void) configureWithPosts:(NSArray *)feedItems;

@end
