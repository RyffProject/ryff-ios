//
//  RYTagFeedViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/1/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYTagFeedViewController.h"

// Custom UI
#import "ODRefreshControl.h"
#import "RYSearchTypeTableViewCell.h"

#define kFeedSection 0
#define kFeedTypeCellReuseID @"typeCell"

@interface RYTagFeedViewController () <SearchTypeDelegate>

// array of strings
@property (nonatomic, strong) NSArray *configurationTags;

@end

@implementation RYTagFeedViewController

#pragma mark -
#pragma mark - ViewController LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.riffSection = 1;
    
    CGFloat searchTypeHeight = kSearchTypeCellHeight;
    self.tableView.contentInset = UIEdgeInsetsMake(searchTypeHeight, 0, 0, 0);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - Configuration

- (void) configureWithTags:(NSArray *)tags
{
    _configurationTags = tags;
}

- (void) fetchContent
{
    [[RYServices sharedInstance] getPostsForTags:_configurationTags searchType:self.searchType page:nil delegate:self];
    [self.refreshControl beginRefreshing];
    
    [self.tableView setContentOffset:CGPointMake(0, -40)];
}

#pragma mark -
#pragma mark - SearchTypeCell Delegate

- (void) searchTypeChosen:(SearchType)searchType
{
    self.searchType = searchType;
    
    [self fetchContent];
}

#pragma mark -
#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows;
    if (section == self.riffSection)
        numRows = [super tableView:tableView numberOfRowsInSection:0];
    else
        numRows = 1;
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == self.riffSection)
        cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:self.riffSection]];
    else
        cell = [self.tableView dequeueReusableCellWithIdentifier:kFeedTypeCellReuseID];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (indexPath.section == self.riffSection)
        height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    else
    {
        // type cell
        height = 40;
    }
    
    return height;
}

#pragma mark -
#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kFeedSection)
    {
        [(RYSearchTypeTableViewCell *)cell configureWithSearchType:self.searchType delegate:self];
    }
    else if (indexPath.section == self.riffSection)
    {
        [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    }
}

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.riffSection)
        return YES;
    else
        return NO;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.riffSection)
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
