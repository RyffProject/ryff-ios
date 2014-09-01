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
    _refreshControl.tintColor = [RYStyleSheet postActionColor];
    _refreshControl.activityIndicatorViewColor = [RYStyleSheet postActionColor];
    [_refreshControl addTarget:self action:@selector(refreshContent:) forControlEvents:UIControlEventValueChanged];
    
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
        
        [[RYServices sharedInstance] getNewsfeedPosts:NEW page:0 delegate:self];
//        [[RYServices sharedInstance] getUserPostsForUser:[RYServices loggedInUser].userId page:nil delegate:self];
    }
    [_refreshControl beginRefreshing];
}

- (void) refreshContent:(ODRefreshControl *)refreshControl
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

#pragma mark -
#pragma mark - Notifications

- (void) userLoggedIn:(NSNotification *)notification
{
    [self fetchContent];
}

@end
