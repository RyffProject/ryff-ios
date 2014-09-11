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
#import "UIViewController+Extras.h"

// Data Managers
#import "RYRegistrationServices.h"
#import "RYServices.h"

// Associated ViewControllers
#import "RYAudioDeckViewController.h"

@interface RYNewsfeedTableViewController ()

// iPad
@property (nonatomic, strong) RYAudioDeckViewController *audioDeckVC;
@end

@implementation RYNewsfeedTableViewController

- (void)viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
    
    [self.tableView setScrollsToTop:YES];
    
    _refreshControl = [[RYRefreshControl alloc] initInScrollView:_tableView];
    _refreshControl.tintColor = [RYStyleSheet postActionColor];
    [_refreshControl addTarget:self action:@selector(refreshContent:) forControlEvents:UIControlEventValueChanged];
    
    // set up test data
    self.feedItems = @[];
    _searchType = NEW;
    [self fetchContent];
    [_refreshControl beginRefreshing];
    
    [self addNewPostButtonToNavBar];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn:) name:kLoggedInNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Configuration

- (void) fetchContent
{
    [[RYServices sharedInstance] getNewsfeedPosts:NEW page:0 delegate:self];
}

- (void) refreshContent:(RYRefreshControl *)refreshControl
{
    [self fetchContent];
}

#pragma mark -
#pragma mark - Post Delegate

- (void) postSucceeded:(NSArray *)posts
{
    [self setFeedItems:posts];
    
    [_refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void) postFailed:(NSString *)reason
{
    [_refreshControl endRefreshing];
}

#pragma mark -
#pragma mark - Notifications

- (void) userLoggedIn:(NSNotification *)notification
{
    [self fetchContent];
}

#pragma mark -
#pragma mark - Overrides

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == self.riffSection)
        return 40.0f;
    else
        return 0.01f;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == self.riffSection)
        return 40.0f;
    else
        return 0.01f;
}

@end
