//
//  RYRiffStreamViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/6/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffStreamViewController.h"

@interface RYRiffStreamViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RYRiffStreamViewController

- (void) viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
}

- (void) configureWithPosts:(NSArray *)feedItems
{
    self.feedItems = feedItems;
}

@end
