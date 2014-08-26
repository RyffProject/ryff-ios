//
//  RYNewsfeedTableViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNewsfeedTableViewController.h"

// UI
#import "ODRefreshControl.h"
#import "UIImage+Color.h"
#import "UIViewController+Extras.h"

// Data Managers
#import "RYServices.h"

// Associated ViewControllers
#import "RYAudioDeckViewController.h"

@interface RYNewsfeedTableViewController () <PostDelegate>

@property (nonatomic, strong) ODRefreshControl *refreshControl;

// Data
@property (nonatomic, assign) SearchType searchType;

// array of strings
@property (nonatomic, strong) NSArray *configurationTags;

// iPad
@property (nonatomic, strong) RYAudioDeckViewController *audioDeckVC;

@end

@implementation RYNewsfeedTableViewController

- (void)viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
    
    // set up test data
    self.feedItems = @[];
    _searchType = NEW;
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
    _refreshControl.tintColor = [RYStyleSheet postActionHighlightedColor];
    _refreshControl.activityIndicatorViewColor = [RYStyleSheet postActionHighlightedColor];
    [_refreshControl addTarget:self action:@selector(refreshContent:) forControlEvents:UIControlEventValueChanged];
    
    _tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    
    [self addNewPostButtonToNavBar];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fetchContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn:) name:kLoggedInNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Configuration

- (void) configureWithTags:(NSArray *)tags
{
    _configurationTags = tags;
}

- (void) fetchContent
{
    if (_configurationTags)
        [[RYServices sharedInstance] getPostsForTags:_configurationTags searchType:_searchType page:nil delegate:self];
    else
    {
        
//        [[RYServices sharedInstance] getNewsfeedPostsForDelegate:self];
        [[RYServices sharedInstance] getUserPostsForUser:[RYServices loggedInUser].userId page:nil delegate:self];
    }
    [_refreshControl beginRefreshing];
}

- (void) refreshContent:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

#pragma mark -
#pragma mark - Post Delegate

- (void) postSucceeded:(NSArray *)posts
{
    [self setFeedItems:posts];
    
    [_refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Notifications

- (void) userLoggedIn:(NSNotification *)notification
{
    [self fetchContent];
}

#pragma mark -
#pragma mark - TableView Overrides

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return 0.01f; }
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return 0.01f; }
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section { return [[UIView alloc] initWithFrame:CGRectZero]; }

@end
