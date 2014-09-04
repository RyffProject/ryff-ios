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
#import "RYNotificationsManager.h"

// Data Objects
#import "RYNotification.h"

// Custom UI
#import "RYNotificationsTableViewCell.h"
#import "ODRefreshControl.h"

#define kNotificationCellReuseID @"notificationCell"

@interface RYNotificationsTableViewController () <NotificationsDelegate>

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
    [self.tableView setContentOffset:CGPointMake(0, -40)];
    
    [self fetchContent];
}

- (void) configureWithDelegate:(id<NotificationSelectionDelegate>)delegate
{
    _delegate = delegate;
}

- (void) fetchContent
{
    [_refControl beginRefreshing];
    
    [[RYNotificationsManager sharedInstance] fetchNotificationsForDelegate:self page:nil];
}

#pragma mark - Actions

- (void) refreshContent:(ODRefreshControl *)refreshControl
{
    [self fetchContent];
}

#pragma mark -
#pragma mark - Notifications Delegate

- (void) notificationsRetrieved:(NSArray *)notifications
{
    _notifications = notifications;
    [self.tableView reloadData];
    [_refControl endRefreshing];
}

- (void) failedNotificationsRetrieval:(NSString *)reason
{
    [_refControl endRefreshing];
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

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

#pragma mark -
#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _notifications.count)
    {
        RYNotification *notification = _notifications[indexPath.row];
        [(RYNotificationsTableViewCell *)cell configureWithNotification:notification];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < _notifications.count)
    {
        RYNotification *notification = _notifications[indexPath.row];
        if (_delegate && [_delegate respondsToSelector:@selector(notificationSelected:)])
            [_delegate notificationSelected:notification];
    }
}

@end
