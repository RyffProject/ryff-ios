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

@interface RYNewsfeedTableViewController ()

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
    [self fetchContent];
    
    [self.tableView setScrollsToTop:YES];
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
    _refreshControl.tintColor = [RYStyleSheet postActionColor];
    _refreshControl.activityIndicatorViewColor = [RYStyleSheet postActionColor];
    [_refreshControl addTarget:self action:@selector(refreshContent:) forControlEvents:UIControlEventValueChanged];
    
//    if (self.navigationController)
//    {
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToTop:)];
//        tapGesture.numberOfTapsRequired    = 2;
//        [self.navigationController.navigationBar addGestureRecognizer:tapGesture];
//    }
    
    [self addNewPostButtonToNavBar];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _tableView.contentInset = UIEdgeInsetsZero;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn:) name:kLoggedInNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) scrollToTop:(UIGestureRecognizer *)tapGesture
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -
#pragma mark - Configuration

- (void) fetchContent
{
    [[RYServices sharedInstance] getNewsfeedPosts:NEW page:0 delegate:self];
//    [[RYServices sharedInstance] getUserPostsForUser:[RYServices loggedInUser].userId page:nil delegate:self];
    
    [_refreshControl beginRefreshing];
    
    [self.tableView setContentOffset:CGPointMake(0, -40)];
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

#pragma mark -
#pragma mark - Overrides

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return 0.01f; }
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.riffSection)
        return 40.0f;
    else
        return 0.01f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

@end
