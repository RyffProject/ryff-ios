//
//  RYRiffDetailsViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 7/30/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffDetailsViewController.h"

// Data Managers
#import "RYDataManager.h"

// Custom UI
#import "RYRiffDetailsTableViewCell.h"

// Associated View Controllers
#import "RYProfileViewController.h"
#import "RYRiffCreateViewController.h"

#define kRiffDetailsCellReuseID @"riffDetails"

@interface RYRiffDetailsViewController () <PostDelegate, RiffDetailsDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, strong) RYNewsfeedPost *post;

// populated with Post objects
@property (nonatomic, strong) NSArray *childrenPosts;

@end

@implementation RYRiffDetailsViewController

- (void) viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
    
    self.riffSection = 0;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[RYServices sharedInstance] getFamily:CHILDREN ForPost:_post.postId delegate:self];
    [self.tableView reloadData];
}

- (void) addBackButton
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(dismissButtonHit:)];
    [self.navigationItem setLeftBarButtonItem:backButton];
}

- (void) dismissButtonHit:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Configuring

- (void) configureForPost:(RYNewsfeedPost *)post
{
    _post = post;
    [self setTitle:post.riff.title];
    
    self.feedItems = @[post];
    
    [[RYDataManager sharedInstance] getRiffFile:post.riff.fileName completion:nil];
}

#pragma mark - Actions

- (IBAction)backButtonHit:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - RiffDetailsDelegate

- (void) riffAvatarTapAction
{
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYProfileViewController *profileVC = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"profileVC"];
    [profileVC configureForUser:_post.user];
    if (self.navigationController)
        [self.navigationController pushViewController:profileVC animated:YES];
    else
        [self presentViewController:profileVC animated:YES completion:nil];
}

#pragma mark -
#pragma mark - PostDelegate

- (void) postFailed:(NSString*)reason
{
    
}

- (void) postSucceeded:(NSArray*)posts
{
    _childrenPosts = posts;
    [_tableView reloadData];
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
        numRows = _childrenPosts.count;
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == self.riffSection)
        cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:self.riffSection]];
    else
        cell = [_tableView dequeueReusableCellWithIdentifier:kRiffDetailsCellReuseID];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (indexPath.section == self.riffSection)
        height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    else
    {
        // riff details cell
        height = 60;
    }
    
    return height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark -
#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.riffSection)
        [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    else
    {
        NSString *actionString = @"riffed on";
        RYNewsfeedPost *post = indexPath.row < _childrenPosts.count ? _childrenPosts[indexPath.row] : nil;
        RYRiffDetailsTableViewCell *detailsCell = (RYRiffDetailsTableViewCell *)cell;
        [detailsCell configureWithPost:post actionString:actionString delegate:self];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section != self.riffSection)
    {
        // push new riff details vc
        RYNewsfeedPost *post = indexPath.row < _childrenPosts.count ? _childrenPosts[indexPath.row] : nil;
        NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
        RYRiffDetailsViewController *riffDetails = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"riffDetails"];
        [riffDetails configureForPost:post];
        [self.navigationController pushViewController:riffDetails animated:YES];
    }
}

@end
