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

// UI Categories
#import "UIImage+Color.h"
#import "UIViewController+RYSocialTransitions.h"

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
    [self.riffTableView registerNib:[UINib nibWithNibName:@"RYRiffCellAvatar" bundle:NULL] forCellReuseIdentifier:KRiffCellAvatarReuseID];
    
    _feedItems = @[];
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
        RYPost *post = self.feedItems[postIdx];
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
    RYPost *post = _feedItems[riffIndex];
    [self pushUserProfileForUser:post.user];
}

/*
 Download/play/pause riff track for post corresponding to riffIndex
 */
- (void) playerControlAction:(NSInteger)riffIndex
{
    RYAudioDeckManager *audioManager = [RYAudioDeckManager sharedInstance];
    RYPost *post = _feedItems[riffIndex];
    if (post.postId == [audioManager currentlyPlayingPost].postId)
    {
        // currently playing
        BOOL shouldPlay = ![audioManager isPlaying];
        [audioManager playTrack:shouldPlay];
    }
    else if ([audioManager idxOfDownload:post] >= 0)
    {
        // currently downloading, should stop download
        [audioManager removePostFromPlaylist:post];
    }
    else
    {
        // not active
        [audioManager forcePostToTop:post];
    }
}

/*
 Upvote post corresponding to riffIndex
 */
- (void) upvoteAction:(NSInteger)riffIndex
{
    RYPost *post = [self.feedItems objectAtIndex:riffIndex];
    [[RYServices sharedInstance] upvote:!post.isUpvoted post:post forDelegate:self];
}

- (void) starAction:(NSInteger)riffIndex
{
    RYPost *post = [self.feedItems objectAtIndex:riffIndex];
    [[RYServices sharedInstance] star:!post.isStarred post:post forDelegate:self];
}

/*
 Repost post corresponding to riffIndex
 */
- (void) repostAction:(NSInteger)riffIndex
{
    RYPost *post = [self.feedItems objectAtIndex:riffIndex];
    RYRiffCreateViewController *riffCreateVC = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"RiffCreateVC"];
    [riffCreateVC includeRiffs:@[post.riffURL]];
    [self presentViewController:riffCreateVC animated:YES completion:nil];
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

- (void) upvoteSucceeded:(RYPost *)updatedPost
{
    [self reloadPost:updatedPost];
}

- (void) starSucceeded:(RYPost *)updatedPost
{
    [self reloadPost:updatedPost];
}

- (void) upvoteFailed:(NSString *)reason post:(RYPost *)oldPost
{
//    [PXAlertView showAlertWithTitle:@"Upvote failed" message:reason];
    
    NSInteger row = [_feedItems indexOfObject:oldPost];
    [self.riffTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:self.riffSection]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void) starFailed:(NSString *)reason post:(RYPost *)oldPost
{
//    [PXAlertView showAlertWithTitle:@"Star post failed" message:reason];
    
    NSInteger row = [_feedItems indexOfObject:oldPost];
    [self.riffTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:self.riffSection]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Internal Helpers

- (void) reloadPost:(RYPost *)post
{
    for (NSInteger postIdx = 0; postIdx < _feedItems.count; postIdx++)
    {
        RYPost *oldPost = _feedItems[postIdx];
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
        RYPost *post = _feedItems[indexPath.row];
        if (post.imageURL)
            cell = [tableView dequeueReusableCellWithIdentifier:kRiffCellReuseID];
        else
            cell = [tableView dequeueReusableCellWithIdentifier:KRiffCellAvatarReuseID];
    }
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRiffCellMinimumHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return 20.0f; }
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return 40.0f; }

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark -
#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RYPost *post = _feedItems[indexPath.row];
    [((RYRiffCell*)cell) configureForPost:post riffIndex:indexPath.row delegate:self];
    [((RYRiffCell *)cell).socialTextView setUserInteractionEnabled:NO];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:_riffSection] animated:YES];
    
    RYPost *post = _feedItems[indexPath.row];
    [self pushRiffDetailsForPost:post];
}

@end
