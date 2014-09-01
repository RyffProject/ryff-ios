//
//  RYRiffStreamingCoreViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffStreamingCoreViewController.h"

// Custom UI
#import "RYStyleSheet.h"
#import "PXAlertView.h"
#import "RYSocialTextView.h"

// Associated View Controllers
#import "RYRiffCreateViewController.h"
#import "RYRiffDetailsViewController.h"
#import "RYProfileViewController.h"

// UI Categories
#import "UIImage+Color.h"

@interface RYRiffStreamingCoreViewController () <FollowDelegate>

// Data
@property (nonatomic, assign) NSInteger openRiffDetailsSection; // section where there the extra riff details section is open

@end

@implementation RYRiffStreamingCoreViewController

#pragma mark -
#pragma mark - View Controller Lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.riffTableView registerNib:[UINib nibWithNibName:@"RYRiffCell" bundle:NULL] forCellReuseIdentifier:kRiffCellReuseID];
    [self.riffTableView registerNib:[UINib nibWithNibName:@"RYRiffCellNoImage" bundle:NULL] forCellReuseIdentifier:kRiffCellNoImageReuseID];
    
    _riffSection = 0;
    _openRiffDetailsSection = -1;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.riffTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.riffTableView setBackgroundColor:[RYStyleSheet lightBackgroundColor]];
}

#pragma mark - Follow Delegate

- (void) follow:(BOOL)following confirmedForUser:(RYUser *)user
{
    for (NSInteger postIdx = 0; postIdx < self.feedItems.count; postIdx++)
    {
        RYNewsfeedPost *post = self.feedItems[postIdx];
        if (post.user.userId == user.userId)
        {
            post.user = user;
            [self.riffTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:postIdx inSection:self.riffSection]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void) followFailed:(NSString *)reason
{
    
}

#pragma mark - ProfilePost Delegate

- (void) avatarAction:(NSInteger)riffIndex
{
    RYNewsfeedPost *post = _feedItems[riffIndex];
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYProfileViewController *profileVC = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"profileVC"];
    [profileVC configureForUser:post.user];
    [self.navigationController pushViewController:profileVC animated:YES];
}

/*
 Download/play/pause riff track for post corresponding to riffIndex
 */
- (void) playerControlAction:(NSInteger)riffIndex
{
    RYNewsfeedPost *post = _feedItems[riffIndex];
    if (post.postId == [[RYAudioDeckManager sharedInstance] currentlyPlayingPost].postId)
    {
        // currently playing
        BOOL shouldPlay = ![[RYAudioDeckManager sharedInstance] isPlaying];
        [[RYAudioDeckManager sharedInstance] playTrack:shouldPlay];
    }
    else
    {
        [[RYAudioDeckManager sharedInstance] forcePostToTop:post];
    }
}

/*
 Upvote post corresponding to riffIndex
 */
- (void) upvoteAction:(NSInteger)riffIndex
{
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:riffIndex];
    [[RYServices sharedInstance] upvote:!post.isUpvoted post:post forDelegate:self];
}

- (void) starAction:(NSInteger)riffIndex
{
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:riffIndex];
    [[RYServices sharedInstance] star:!post.isStarred post:post forDelegate:self];
}

/*
 Repost post corresponding to riffIndex
 */
- (void) repostAction:(NSInteger)riffIndex
{
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:riffIndex];
    if (post.riff)
    {
        RYRiffCreateViewController *riffCreateVC = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"RiffCreateVC"];
        [riffCreateVC includeRiffs:@[post.riff]];
        [self presentViewController:riffCreateVC animated:YES completion:nil];
    }
}

///*
// Delete post button hit. Should have services do so
// */
//- (void) deleteHit:(NSInteger)riffIndex
//{
//    RYNewsfeedPost *post = [self.feedItems objectAtIndex:riffIndex];
//    BlockAlertView *deleteAlert = [[BlockAlertView alloc] initWithTitle:@"Delete Riff?" message:[NSString stringWithFormat:@"Are you sure you wish to delete %@?",post.riff.title] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
//    [deleteAlert setDidDismissBlock:^(BlockAlertView *alertView, NSInteger buttonIndex) {
//        
//        if (buttonIndex != alertView.cancelButtonIndex)
//        {
//            // delete post
//            NSMutableArray *mutableFeedItems = [_feedItems mutableCopy];
//            [mutableFeedItems removeObjectAtIndex:riffIndex];
//            [_riffTableView beginUpdates];
//            _feedItems = mutableFeedItems;
//            [_riffTableView deleteSections:[NSIndexSet indexSetWithIndex:riffIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
//            _openRiffDetailsSection = -1;
//            [_riffTableView endUpdates];
//            [[RYServices sharedInstance] deletePost:post];
//        }
//    }];
//    [deleteAlert show];
//}

#pragma mark -
#pragma mark - Action Delegate

- (void) upvoteSucceeded:(RYNewsfeedPost *)updatedPost
{
    [self reloadPost:updatedPost];
}

- (void) starSucceeded:(RYNewsfeedPost *)updatedPost
{
    [self reloadPost:updatedPost];
}

- (void) upvoteFailed:(NSString *)reason post:(RYNewsfeedPost *)oldPost
{
//    [PXAlertView showAlertWithTitle:@"Upvote failed" message:reason];
    
    NSInteger row = [_feedItems indexOfObject:oldPost];
    [self.riffTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:self.riffSection]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void) starFailed:(NSString *)reason post:(RYNewsfeedPost *)oldPost
{
//    [PXAlertView showAlertWithTitle:@"Star post failed" message:reason];
    
    NSInteger row = [_feedItems indexOfObject:oldPost];
    [self.riffTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:self.riffSection]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Internal Helpers

- (void) reloadPost:(RYNewsfeedPost *)post
{
    for (NSInteger postIdx = 0; postIdx < _feedItems.count; postIdx++)
    {
        RYNewsfeedPost *oldPost = _feedItems[postIdx];
        if (oldPost.postId == post.postId)
        {
            // found the old post, replace it and update UI
            NSMutableArray *mutableFeedItems = [_feedItems mutableCopy];
            [mutableFeedItems replaceObjectAtIndex:postIdx withObject:post];
            _feedItems = mutableFeedItems;
            [_riffTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:postIdx inSection:self.riffSection]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark -
#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _feedItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row < _feedItems.count)
    {
        RYNewsfeedPost *post = _feedItems[indexPath.row];
        if (post.imageURL)
            cell = [tableView dequeueReusableCellWithIdentifier:kRiffCellReuseID];
        else
            cell = [tableView dequeueReusableCellWithIdentifier:kRiffCellNoImageReuseID];
    }
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (indexPath.row < _feedItems.count)
    {
        // profile post -> calculate size with attributed text for post description
        RYNewsfeedPost *post              = _feedItems[indexPath.row];
        CGFloat widthMinusText;
        if (post.imageURL)
            widthMinusText                = kRiffCellWidthMinusText;
        else
            widthMinusText                = kRiffCellWidthMinusTextNoImage;
        
        CGSize boundingSize               = CGSizeMake(self.riffTableView.frame.size.width-widthMinusText, 20000);
        NSAttributedString *postString    = [[NSAttributedString alloc] initWithString:post.content attributes:@{NSFontAttributeName: [UIFont fontWithName:kRegularFont size:18.0f]}];
        UITextView *sizingTextView        = [[UITextView alloc] init];
        sizingTextView.textContainerInset = UIEdgeInsetsZero;
        [sizingTextView setAttributedText:postString];
        height = [sizingTextView sizeThatFits:boundingSize].height;
        
        height = MAX(height+kRiffCellHeightMinusText, kRiffCellMinimumHeight);
    }
    
    return height;
}

#pragma mark -
#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RYNewsfeedPost *post = _feedItems[indexPath.row];
    [((RYRiffCell*)cell) configureForPost:post riffIndex:indexPath.row delegate:self];
    [((RYRiffCell *)cell).socialTextView setUserInteractionEnabled:NO];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:_riffSection] animated:YES];
    
    RYNewsfeedPost *post = _feedItems[indexPath.row];
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYRiffDetailsViewController *riffDetails = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"riffDetails"];
    [riffDetails configureForPost:post familyType:CHILDREN];
    [self.navigationController pushViewController:riffDetails animated:YES];
}

@end
