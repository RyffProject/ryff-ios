//
//  RYRiffDetailsViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 7/30/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffDetailsViewController.h"

// Data Managers
#import "RYServices.h"
#import "RYDataManager.h"

// Custom UI
#import "RYRiffDetailsTableViewCell.h"

// Associated View Controllers
#import "RYProfileViewController.h"
#import "RYRiffCreateViewController.h"

#define kRiffDetailsCellReuseID @"riffDetails"

@interface RYRiffDetailsViewController () <PostDelegate, RiffDetailsDelegate, UpvoteDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AVAudioPlayer *riffPlayer;

@property (nonatomic, weak) RYRiffDetailsTableViewCell *riffDetailsCell;

// Data
@property (nonatomic, strong) RYNewsfeedPost *post;

@end

@implementation RYRiffDetailsViewController

- (void) viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
    
    self.riffSection = 1;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[RYServices sharedInstance] getFamilyForPost:_post.postId delegate:self];
    [self.tableView reloadData];
}

#pragma mark - Configuring

- (void) configureForPost:(RYNewsfeedPost *)post atPlaybackPosition:(CGFloat)playbackPosition
{
    _post = post;
    [[RYDataManager sharedInstance] getRiffFile:post.riff.fileName completion:^(BOOL success, NSString *localPath) {
        if (success)
        {
            NSError *error = nil;
            _riffPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:localPath] error:&error];
            if (!error && playbackPosition > 0)
            {
                // resume playing at appropriate point
                [self clearRiff];
                [_riffPlayer playAtTime:playbackPosition];
            }
        }
    }];
}

#pragma mark -
#pragma mark - Media Overrides

- (void) clearRiff
{
    [_riffPlayer stop];
    [_riffDetailsCell setPlayProgress:0.0f];
    [super clearRiff];
}

- (void) updateTimeLeft
{
    if (_riffPlayer && [_riffPlayer isPlaying])
    {
        CGFloat progress = _riffPlayer.currentTime / _riffPlayer.duration;
        [_riffDetailsCell setPlayProgress:progress];
    }
    [super updateTimeLeft];
}

#pragma mark -
#pragma mark - RiffDetailsDelegate

- (void) riffUpvoteAction
{
    [[RYServices sharedInstance] upvote:YES post:_post.postId forDelegate:self];
}

- (void) riffRepostAction
{
    RYRiffCreateViewController *riffCreateVC = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"RiffCreateVC"];
    [riffCreateVC includeRiffs:@[_post.riff]];
    [self presentViewController:riffCreateVC animated:YES completion:nil];
}

- (void) riffFollowAction
{
    
}

- (void) riffProgressSliderChanged:(CGFloat)newProgress
{
    if (_riffPlayer && [_riffPlayer isPlaying])
        [_riffPlayer playAtTime:newProgress*_riffPlayer.duration];
}

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

- (void) riffPlayControlAction
{
    if (_riffPlayer)
    {
        if ([_riffPlayer isPlaying])
        {
            [_riffPlayer pause];
            [_riffDetailsCell shouldPause:YES];
        }
        else
        {
            [super clearRiff];
            [_riffPlayer play];
            [_riffDetailsCell shouldPause:NO];
        }
    }
}

#pragma mark -
#pragma mark - PostDelegate

- (void) postFailed:(NSString*)reason
{
    
}

- (void) postSucceeded:(NSArray*)posts
{
    self.feedItems = posts;
    [_tableView reloadData];
}

#pragma mark - Upvote Delegate

- (void) upvoteFailed:(NSString *)reason
{
    
}

- (void) upvoteSucceeded:(RYNewsfeedPost *)updatedPost
{
    if (updatedPost.postId == _post.postId)
    {
        // upvoted main riff
        _post = updatedPost;
        [_riffDetailsCell configureWithPost:_post delegate:self];
    }
    else
    {
        // upvoted other riff in tableview
        [super upvoteSucceeded:updatedPost];
    }
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
        cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
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
        // riff details cell -> calculate size with attributed text for post description
        CGFloat widthMinusText = kRiffDetailsWidthMinusText;
        height = [[RYStyleSheet createProfileAttributedTextWithPost:_post] boundingRectWithSize:CGSizeMake(self.riffTableView.frame.size.width-widthMinusText, 20000) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        height = MAX(height+kRiffDetailsCellHeightMinusText, kRiffDetailsCellMinimumHeight);
    }
    
    return height;
}

#pragma mark -
#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.riffSection)
        [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    else
    {
        _riffDetailsCell = (RYRiffDetailsTableViewCell *)cell;
        [_riffDetailsCell configureWithPost:_post delegate:self];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == self.riffSection)
        [super tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
}

@end
