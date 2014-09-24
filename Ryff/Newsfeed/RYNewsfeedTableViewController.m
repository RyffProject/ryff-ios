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
    
    _tableView.scrollsToTop = YES;
    
    _refreshControl = [[RYRefreshControl alloc] initInScrollView:_tableView];
    _refreshControl.tintColor = [RYStyleSheet postActionColor];
    [_refreshControl addTarget:self action:@selector(refreshContent:) forControlEvents:UIControlEventValueChanged];
    
    _loadMoreControl = [[RYLoadMoreControl alloc] initInScrollView:_tableView];
    _loadMoreControl.tintColor = [RYStyleSheet postActionColor];
    [_loadMoreControl addTarget:self action:@selector(loadMoreContent:) forControlEvents:UIControlEventValueChanged];
    
    // set up test data
    _searchType = NEW;
    
    [self addNewPostButtonToNavBar];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.feedItems || self.feedItems.count == 0)
    {
        [_refreshControl beginRefreshing];
        [self fetchContent:0];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn:) name:kLoggedInNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Configuration

- (void) fetchContent:(NSInteger)page
{
    [[RYServices sharedInstance] getNewsfeedPostsWithPage:@(page) delegate:self];
}

- (void) refreshContent:(RYRefreshControl *)refreshControl
{
    [self fetchContent:0];
}

- (void) loadMoreContent:(RYLoadMoreControl *)loadMoreControl
{
    [self fetchContent:(_currentPage+1)];
}

#pragma mark -
#pragma mark - Post Delegate

- (void) postSucceeded:(NSArray *)posts page:(NSNumber *)page
{
    if (page && page > 0)
        self.feedItems = [self.feedItems arrayByAddingObjectsFromArray:posts];
    else
        self.feedItems = posts;
    
    _currentPage = page.integerValue;
    [_refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void) postFailed:(NSString *)reason page:(NSNumber *)page
{
    self.feedItems = nil;
    [_refreshControl endRefreshing];
    [self.riffTableView reloadData];
}

#pragma mark -
#pragma mark - Notifications

- (void) userLoggedIn:(NSNotification *)notification
{
    [self fetchContent:0];
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
