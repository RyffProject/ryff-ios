//
//  RYTagFeedViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/1/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYTagFeedViewController.h"

// Data Objects
#import "RYTag.h"

// Custom UI
#import "RYSearchTypeTableViewCell.h"

#define kFeedSection 0
#define kFeedTypeCellReuseID @"typeCell"

@interface RYTagFeedViewController () <SearchTypeDelegate>

// array of strings
@property (nonatomic, strong) NSArray *configurationTags;

@property (nonatomic, assign) BOOL didAppear;

@end

@implementation RYTagFeedViewController

#pragma mark -
#pragma mark - ViewController LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.searchType = TRENDING;
    [self styleWithTags];
    
    self.riffSection = 1;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _didAppear = YES;
}

#pragma mark - Configuration

- (void) configureWithTags:(NSArray *)tags
{
    _configurationTags = tags;
    
    if (_didAppear)
        [self styleWithTags];
}

- (void) styleWithTags
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel *titleLabel = [[UILabel alloc] init];
    NSMutableString *tagString = [[NSMutableString alloc] initWithString:@""];
    for (NSInteger tagIdx = 0; tagIdx < _configurationTags.count; tagIdx++)
    {
        NSString *tag = _configurationTags[tagIdx];
        [tagString appendString:tag];
        if (tagIdx < _configurationTags.count - 1)
            [tagString appendString:@", "];
    }
    
    NSString *searchTypeString;
    switch (self.searchType) {
        case TRENDING:
            searchTypeString = @"Trending";
            break;
        case NEW:
            searchTypeString = @"New";
            break;
        case TOP:
            searchTypeString = @"Top";
            break;
    }
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:tagString attributes:@{NSFontAttributeName: [UIFont fontWithName:kRegularFont size:18.0f]}];
    NSAttributedString *attSearchString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@",searchTypeString] attributes:@{NSFontAttributeName: [UIFont fontWithName:kRegularFont size:14.0f]}];
    [attString appendAttributedString:attSearchString];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attString.string.length)];
    
    titleLabel.attributedText = attString;
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel sizeToFit];
    
    if (tagString.length > 20)
    {
        NSArray *tags = [tagString componentsSeparatedByString:@","];
        if (tags.count > 2)
            tagString = [[NSString stringWithFormat:@"%@%@ and %lu more",tags[0],tags[1],(tags.count-2)] mutableCopy];
    }
    self.title = tagString;
    
    [titleView addSubview:titleLabel];
    
    CGFloat adjustment = (self.navigationController.navigationBar.frame.size.height - titleView.frame.size.height)/2.0f;
    titleLabel.center = CGPointMake(titleView.frame.size.width/2, titleView.frame.size.height/2-adjustment);
    self.navigationItem.titleView = titleView;
}

- (void) fetchContent
{
    [[RYServices sharedInstance] getPostsForTags:_configurationTags searchType:self.searchType page:nil limit:nil delegate:self];
}

#pragma mark -
#pragma mark - Post Delegate

- (void) postSucceeded:(NSArray *)posts page:(NSNumber *)page
{
    [super postSucceeded:posts page:page];
    [self configureWithTags:_configurationTags];
}

- (void) postFailed:(NSString *)reason page:(NSNumber *)page
{
    [self.refreshControl endRefreshing];
}

#pragma mark -
#pragma mark - SearchTypeCell Delegate

- (void) searchTypeChosen:(SearchType)searchType
{
    self.searchType = searchType;
    
    [self.refreshControl beginRefreshing];
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
