//
//  RYTagListViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYTagListViewController.h"

// Data Managers
#import "RYDiscoverServices.h"

// Data Objects
#import "RYTag.h"
#import "RYTagList.h"

// Custom UI
#import "RYTagListCollectionTableViewCell.h"

// Associated View Controllers
#import "RYTagFeedViewController.h"

#define kTagListTableCellReuseID @"tagListCell"

@interface RYTagListViewController () <TagListCollectionDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, strong) NSArray *tagLists;

@end

@implementation RYTagListViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    RYTagList *trending = [[RYTagList alloc] initWithTagListType:TRENDING_LIST];
    RYTagList *suggested = [[RYTagList alloc] initWithTagListType:SUGGESTED_LIST];
    
    [trending fetchData];
    [suggested fetchData];
    
    _tagLists = @[trending, suggested];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    
    self.view.backgroundColor = [RYStyleSheet profileBackgroundColor];
    
    self.title = @"Discover";
}

#pragma mark -
#pragma mark - TagList Collection Delegate

- (void) tagSelected:(RYTag *)tag
{
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYTagFeedViewController *tagFeed = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"tagFeedVC"];
    [tagFeed configureWithTags:@[tag.tag]];
    [self.navigationController pushViewController:tagFeed animated:YES];
}

#pragma mark -
#pragma mark - TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tagLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTagListTableCellReuseID];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark -
#pragma mark - TableView Delegate

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return 0.01f; }
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return 0.01f; }

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 235.0f;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RYTagList *list = _tagLists[indexPath.row];
    RYTagListCollectionTableViewCell *tagListCell = (RYTagListCollectionTableViewCell *)cell;
    [tagListCell configureWithTagList:list delegate:self];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
