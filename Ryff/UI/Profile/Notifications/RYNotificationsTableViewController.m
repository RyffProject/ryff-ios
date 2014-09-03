//
//  RYNotificationsTableViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNotificationsTableViewController.h"

// Data Managers
#import "RYStyleSheet.h"

// Custom UI
#import "RYNotificationsTableViewCell.h"
#import "ODRefreshControl.h"

#define kNotificationCellReuseID @"notificationCell"

@interface RYNotificationsTableViewController ()

@property (nonatomic, strong) ODRefreshControl *refControl;

// Data
@property (nonatomic, strong) NSArray *notifications;
@property (nonatomic, weak) id<NotificationSelectionDelegate> delegate;

@end

@implementation RYNotificationsTableViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _refControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    _refControl.tintColor = [RYStyleSheet postActionColor];
    _refControl.activityIndicatorViewColor = [RYStyleSheet postActionColor];
    [_refControl addTarget:self action:@selector(refreshContent:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 20)];
    [self.tableView setSeparatorColor:[RYStyleSheet availableActionColor]];
    
    [self fetchContent];
}

- (void) configureWithDelegate:(id<NotificationSelectionDelegate>)delegate
{
    _delegate = delegate;
}

- (void) fetchContent
{
    [_refControl beginRefreshing];
    
    [self.tableView setContentOffset:CGPointMake(0, -40)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_refControl endRefreshing];
    });
}

#pragma mark - Actions

- (void) refreshContent:(ODRefreshControl *)refreshControl
{
    [self fetchContent];
}

#pragma mark -
#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:kNotificationCellReuseID forIndexPath:indexPath];
}

#pragma mark -
#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // prepare cell
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
