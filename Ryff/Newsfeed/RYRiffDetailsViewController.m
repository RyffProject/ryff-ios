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
#import "RYPostImageTableViewCell.h"
#import "RYRiffDetailsTableViewCell.h"
#import "RYSocialTextView.h"

// Associated View Controllers
#import "RYProfileViewController.h"
#import "RYRiffCreateViewController.h"
#import "RYTagFeedViewController.h"
#import "RYRiffStreamViewController.h"

// Categories
#import "UIViewController+Extras.h"
#import "UIImageView+SGImageCache.h"

#define kPostImageCellReuseID @"postImageCell"
#define kRiffDetailsCellReuseID @"riffDetails"

#define kParentPostsInfoSection (_parentPosts.count > 0) ? 1 : -1
#define kPostImageRow (_post.imageURL && indexPath.row == 0)

@interface RYRiffDetailsViewController () <FamilyPostDelegate, RiffDetailsDelegate, SocialTextViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, strong) RYNewsfeedPost *post;

// populated with Post objects
@property (nonatomic, strong) NSArray *childrenPosts;
@property (nonatomic, strong) NSArray *parentPosts;

@end

@implementation RYRiffDetailsViewController

- (void) viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
    
    self.riffSection = 0;
    [[RYServices sharedInstance] getFamilyForPost:_post.postId delegate:self];
    
    if (_shouldPreventNavigation)
        _tableView.allowsSelection = NO;
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
    if (_shouldPreventNavigation)
        return;
    
    if (postIdx < _childrenPosts.count)
    {
        RYNewsfeedPost *selectedPost = _childrenPosts[postIdx];
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
#pragma mark - SocialTextView Delegate

- (void) presentProfileForUsername:(NSString *)username
{
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYProfileViewController *profileVC = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"profileVC"];
    [profileVC configureForUsername:username];
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void) presentNewsfeedForTag:(NSString *)tag
{
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYTagFeedViewController *tagFeedVC = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"tagFeedVC"];
    [tagFeedVC configureWithTags:@[tag]];
    [self.navigationController pushViewController:tagFeedVC animated:YES];
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
#pragma mark - Overrides

- (void) avatarAction:(NSInteger)riffIndex
{
    if (!_shouldPreventNavigation)
        [super avatarAction:riffIndex];
}

#pragma mark -
#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = 1;
    if (_childrenPosts.count > 0)
        sectionCount++;
    if (_parentPosts.count > 0)
        sectionCount++;
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows;
    if (section == self.riffSection)
    {
        numRows = [super tableView:tableView numberOfRowsInSection:0];
        if (_post.imageURL)
            numRows++; // row for image
    }
    else if (section == kParentPostsInfoSection)
    {
        // provide one cell for description of parents
        numRows = 1;
    }
    else
    {
        numRows = _childrenPosts.count;
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == self.riffSection)
    {
        if (kPostImageRow)
            cell = [tableView dequeueReusableCellWithIdentifier:kPostImageCellReuseID];
        else
            cell = [tableView dequeueReusableCellWithIdentifier:KRiffCellAvatarReuseID];
    }
    else
        cell = [tableView dequeueReusableCellWithIdentifier:kRiffDetailsCellReuseID];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (indexPath.section == self.riffSection)
    {
        if (kPostImageRow)
            height = 230.0f;
        else
        {
            // riff details -> calculate size with attributed text for post description
            NSInteger postIdx                 = _post.imageURL ? (indexPath.row-1) : indexPath.row;
            RYNewsfeedPost *post              = self.feedItems[postIdx];
            CGFloat widthMinusText            = kRiffCellWidthMinusTextAvatar;
            
            CGSize boundingSize               = CGSizeMake(self.riffTableView.frame.size.width-widthMinusText, 20000);
            NSAttributedString *postString    = [[NSAttributedString alloc] initWithString:post.content attributes:@{NSFontAttributeName: [UIFont fontWithName:kRegularFont size:18.0f]}];
            UITextView *sizingTextView        = [[UITextView alloc] init];
            sizingTextView.textContainerInset = UIEdgeInsetsZero;
            [sizingTextView setAttributedText:postString];
            height = [sizingTextView sizeThatFits:boundingSize].height;
            
            height = MAX(height+kRiffCellHeightMinusText, kRiffCellMinimumHeight);
        }
    }
    else
    {
        // riff details cell
        height = 60;
    }
    
    return height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 15.0f;
    if (section == self.riffSection)
        height = [super tableView:tableView heightForHeaderInSection:section];
    else if (section == kParentPostsInfoSection)
        height = 0.01f;
    return height;
}

#pragma mark -
#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger parentInfoSection = kParentPostsInfoSection;
    
    if (indexPath.section == self.riffSection)
    {
        if (kPostImageRow)
        {
            [((RYPostImageTableViewCell *)cell).centerImageView setImageForURL:_post.imageURL.absoluteString placeholder:[UIImage imageNamed:@"user"]];
            [cell setBackgroundColor:[UIColor clearColor]];
        }
        else
        {
            RYRiffCell *riffCell = (RYRiffCell*)cell;
            NSInteger postIdx    = _post.imageURL ? (indexPath.row-1) : indexPath.row;
            [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:postIdx inSection:0]];
            [riffCell.socialTextView setUserInteractionEnabled:YES];
            [riffCell.socialTextView.textContainer setLineBreakMode:NSLineBreakByWordWrapping];
            [riffCell.socialTextView setSocialDelegate:self];
        }
    }
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
        NSString *actionString = @"sampled on";
        RYNewsfeedPost *post = indexPath.row < _childrenPosts.count ? _childrenPosts[indexPath.row] : nil;
        RYRiffDetailsTableViewCell *detailsCell = (RYRiffDetailsTableViewCell *)cell;
        [detailsCell configureWithPost:post postIdx:indexPath.row actionString:actionString delegate:self];
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
        RYRiffStreamViewController *riffStream = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"riffStream"];
        [riffStream configureWithPosts:_parentPosts];
        riffStream.title = [NSString stringWithFormat:@"Posts Sampled in %@",_post.riff.title];
        [self.navigationController pushViewController:riffStream animated:YES];
    }
    else if (indexPath.section != self.riffSection)
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
