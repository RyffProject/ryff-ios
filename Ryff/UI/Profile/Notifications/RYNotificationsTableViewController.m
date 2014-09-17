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
#import "RYRefreshControl.h"

#define kNotificationCellReuseID @"notificationCell"

@interface RYNotificationsTableViewController () <NotificationsDelegate>

@property (nonatomic, strong) RYRefreshControl *refControl;

// Data
@property (nonatomic, strong) NSArray *notifications;
@property (nonatomic, weak) id<NotificationSelectionDelegate> delegate;

@end

@implementation RYNotificationsTableViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _refControl = [[RYRefreshControl alloc] initInScrollView:self.tableView];
    _refControl.tintColor = [RYStyleSheet postActionColor];
    [_refControl addTarget:self action:@selector(refreshContent:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.backgroundColor = [RYStyleSheet lightBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsZero;
    
    [_refControl beginRefreshing];
    [self fetchContent];
}

- (void) configureWithDelegate:(id<NotificationSelectionDelegate>)delegate
{
    _delegate = delegate;
}

- (void) fetchContent
{
    [[RYNotificationsManager sharedInstance] fetchNotificationsForDelegate:self page:nil];
}

#pragma mark - Actions

- (void) refreshContent:(RYRefreshControl *)refreshControl
{
    [self fetchContent];
}

#pragma mark -
#pragma mark - Notifications Delegate

- (void) notificationsRetrieved:(NSArray *)notifications
{
    _notifications = notifications;
    [_refControl endRefreshing];
    [self.tableView reloadData];
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
    RYNotification *notification = _notifications[indexPath.row];
    NSAttributedString *notificationString = [RYNotificationsManager notificationString:notification];
    CGFloat labelWidth = self.view.frame.size.width-kNotificationsCellWidthMinusText;
    CGRect allowedFrame = [notificationString boundingRectWithSize:CGSizeMake(labelWidth, 20000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:NULL];
    return allowedFrame.size.height + kNotificationsCellHeightMinusText;
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
