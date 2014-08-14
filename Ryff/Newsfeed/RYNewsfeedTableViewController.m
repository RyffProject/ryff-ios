//
//  RYNewsfeedTableViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNewsfeedTableViewController.h"

// UI
#import "UIImage+Color.h"

// Data Managers
#import "RYServices.h"

@interface RYNewsfeedTableViewController () <PostDelegate>

@end

@implementation RYNewsfeedTableViewController

- (void)viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
    
    // set up test data
    self.feedItems = @[];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [[RYServices sharedInstance] getNewsfeedPostsForDelegate:self];
    [[RYServices sharedInstance] getUserPostsForUser:[RYServices loggedInUser].userId Delegate:self];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark - Post Delegate

- (void) postSucceeded:(NSArray *)posts
{
    [self setFeedItems:posts];
    [self.tableView reloadData];
}

@end
