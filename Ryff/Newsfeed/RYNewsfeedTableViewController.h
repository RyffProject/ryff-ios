//
//  RYNewsfeedTableViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYRiffStreamingCoreViewController.h"

@interface RYNewsfeedTableViewController : RYRiffStreamingCoreViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void) configureWithTags:(NSArray *)tags;

@end
