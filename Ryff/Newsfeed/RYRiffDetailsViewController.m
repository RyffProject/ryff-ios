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

#define kParentPostsInfoSection (_parentPosts.count > 0 && _familyType == CHILDREN) ? 1 : -1

@interface RYRiffDetailsViewController () <FamilyPostDelegate, RiffDetailsDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, strong) RYNewsfeedPost *post;
@property (nonatomic, assign) FamilyType familyType;

// populated with Post objects
@property (nonatomic, strong) NSArray *childrenPosts;
@property (nonatomic, strong) NSArray *parentPosts;

@end

@implementation RYRiffDetailsViewController

- (void) viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
    
    if (_familyType == CHILDREN)
        self.riffSection = 0;
    else
        self.riffSection = -1;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[RYServices sharedInstance] getFamilyForPost:_post.postId delegate:self];
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

- (void) configureForPost:(RYNewsfeedPost *)post familyType:(FamilyType)familyType
{
    _post = post;
    _familyType = familyType;
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

- (void) riffAvatarTapAction:(NSInteger)postIdx
{
    NSArray *postArray = (_familyType == CHILDREN) ? _childrenPosts : _parentPosts;
    if (postIdx < postArray.count)
    {
        RYNewsfeedPost *selectedPost = postArray[postIdx];
        NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
        RYProfileViewController *profileVC = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"profileVC"];
        [profileVC configureForUser:selectedPost.user];
        if (self.navigationController)
            [self.navigationController pushViewController:profileVC animated:YES];
        else
            [self presentViewController:profileVC animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark - PostDelegate

- (void) childrenRetrieved:(NSArray *)childPosts
{
    _childrenPosts = childPosts;
    [_tableView reloadData];
}

- (void) parentsRetrieved:(NSArray *)parentPosts
{
    _parentPosts = parentPosts;
    [_tableView reloadData];
}

#pragma mark -
#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = 1;
    if (_familyType == CHILDREN)
    {
        if (_childrenPosts.count > 0)
            sectionCount++;
        if (_parentPosts.count > 0)
            sectionCount++;
    }
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows;
    if (section == self.riffSection)
        numRows = [super tableView:tableView numberOfRowsInSection:0];
    else if (_familyType == CHILDREN && section == 1)
    {
        // provide one cell for description
        numRows = 1;
    }
    else
    {
        NSArray *postArray = (_familyType == CHILDREN) ? _childrenPosts : _parentPosts;
        numRows = postArray.count;
    }
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
    NSInteger parentInfoSection = kParentPostsInfoSection;
    
    if (indexPath.section == self.riffSection)
        [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    else if (indexPath.section == parentInfoSection)
    {
        NSMutableAttributedString *username = [[NSMutableAttributedString alloc] initWithString:_post.user.username attributes:@{NSFontAttributeName: [UIFont fontWithName:kBoldFont size:18.0f]}];
        NSAttributedString *action   = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" sampled %lu riffs", (unsigned long)_parentPosts.count] attributes:@{NSFontAttributeName : [UIFont fontWithName:kRegularFont size:18.0f]}];
        [username appendAttributedString:action];
        
        RYRiffDetailsTableViewCell *detailsCell = (RYRiffDetailsTableViewCell *)cell;
        [detailsCell configureWithAttributedString:username imageURL:_post.user.avatarURL];
    }
    else
    {
        NSString *actionString = (_familyType == CHILDREN) ? @"sampled on" : @"sampled";
        NSArray *postArray = (_familyType == CHILDREN) ? _childrenPosts : _parentPosts;
        RYNewsfeedPost *post = indexPath.row < postArray.count ? postArray[indexPath.row] : nil;
        RYRiffDetailsTableViewCell *detailsCell = (RYRiffDetailsTableViewCell *)cell;
        if (_familyType == CHILDREN)
            [detailsCell configureWithPost:post postIdx:indexPath.row actionString:actionString delegate:self];
        else
            [detailsCell configureWithSampledPost:post user:_post.user postIdx:indexPath.row actionString:actionString delegate:self];
    }
}

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.riffSection)
        return NO;
    
    return YES;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger parentInfoSection = kParentPostsInfoSection;
    if (indexPath.section == parentInfoSection)
    {
        NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
        RYRiffDetailsViewController *riffDetails = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"riffDetails"];
        [riffDetails configureForPost:_post familyType:PARENTS];
        [self.navigationController pushViewController:riffDetails animated:YES];
    }
    else if (indexPath.section != self.riffSection)
    {
        // push new riff details vc
        NSArray *postArray = (_familyType == CHILDREN) ? _childrenPosts : _parentPosts;
        RYNewsfeedPost *post = indexPath.row < postArray.count ? postArray[indexPath.row] : nil;
        NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
        RYRiffDetailsViewController *riffDetails = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"riffDetails"];
        [riffDetails configureForPost:post familyType:CHILDREN];
        [self.navigationController pushViewController:riffDetails animated:YES];
    }
}

@end
