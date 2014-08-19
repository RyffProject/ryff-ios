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
#import "BlockAlertView.h"

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

- (void) followConfirmed:(NSInteger)userID
{
    for (RYNewsfeedPost *post in self.feedItems)
    {
        if (post.user.userId == userID)
            post.user.isFollowing = YES;
    }
    
    [self.riffTableView reloadData];
}

- (void) unfollowConfirmed:(NSInteger)userID
{
    for (RYNewsfeedPost *post in self.feedItems)
    {
        if (post.user.userId == userID)
            post.user.isFollowing = NO;
    }
    
    [self.riffTableView reloadData];
}

- (void) followFailed
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
    UIAlertView *upvoteFailedAlert = [[UIAlertView alloc] initWithTitle:@"Upvote failed" message:reason delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [upvoteFailedAlert show];
    
    [self reloadPost:oldPost];
}

- (void) starFailed:(NSString *)reason post:(RYNewsfeedPost *)oldPost
{
    UIAlertView *upvoteFailedAlert = [[UIAlertView alloc] initWithTitle:@"Upvote failed" message:reason delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [upvoteFailedAlert show];
    
    [self reloadPost:oldPost];
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
    return [tableView dequeueReusableCellWithIdentifier:kRiffCellReuseID];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (indexPath.row < _feedItems.count)
    {
        // profile post -> calculate size with attributed text for post description
        RYNewsfeedPost *post = _feedItems[indexPath.row];
        CGFloat widthMinusText = kRiffCellWidthMinusText;
        height = [[RYStyleSheet createProfileAttributedTextWithPost:post] boundingRectWithSize:CGSizeMake(self.riffTableView.frame.size.width-widthMinusText, 20000) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        height = MAX(height+kRiffCellHeightMinusText, kRiffCellMinimumHeight);
    }
    
    return height;
}

#pragma mark -
#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RYNewsfeedPost *post = _feedItems[indexPath.row];
    [((RYRiffCell*)cell) configureForPost:post attributedText:[RYStyleSheet createProfileAttributedTextWithPost:post] riffIndex:indexPath.row delegate:self];
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
