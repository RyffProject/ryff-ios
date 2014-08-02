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

// UI Categories
#import "UIImage+Color.h"

@interface RYRiffStreamingCoreViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, RiffCellDelegate>

@property (nonatomic, strong) NSTimer *updateTimer;

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
    
    _updateTimer= [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateTimeLeft) userInfo:nil repeats:YES];
    
    _riffSection = 0;
    _openRiffDetailsSection = -1;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.riffTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.riffTableView setBackgroundColor:[RYStyleSheet backgroundColor]];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self clearRiff];
}


#pragma mark -
#pragma mark - Riff Downloading / Playing

- (void) startRiffDownload:(RYRiff*)riff
{
    _isDownloading = YES;
    [_currentlyPlayingCell startDownloading];
    
    NSURL *riffURL = riff.URL;
    NSURLRequest *dataRequest = [NSURLRequest requestWithURL:riffURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:45];
    _riffData = [[NSMutableData alloc] initWithLength:0];
    _riffConnection = [[NSURLConnection alloc] initWithRequest:dataRequest delegate:self startImmediately:YES];
}

- (void) startRiffPlaying:(NSData*)riffData
{
    if (!_audioPlayer.isPlaying)
    {
        NSError *error;
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:riffData error:&error];
        [_audioPlayer setDelegate:self];
        _audioPlayer.numberOfLoops = 0;
        _audioPlayer.volume = 1.0f;
        [_audioPlayer prepareToPlay];
        
        if (_audioPlayer == nil)
            NSLog(@"Error: %@", [error localizedDescription]);
        else
        {
            [_audioPlayer play];
        }
    }
}

- (void) clearRiff
{
    [_currentlyPlayingCell clearAudio];
    _currentlyPlayingCell = nil;
    [_audioPlayer stop];
    _audioPlayer = nil;
    _totalBytes = 0;
    _riffData = nil;
    _riffConnection = nil;
    _audioPlayer = nil;
    _isDownloading = NO;
}

#pragma mark -
#pragma mark - Timer UI Update

- (void)updateTimeLeft
{
    if (_audioPlayer && [_audioPlayer isPlaying])
    {
        CGFloat timeProgress = _audioPlayer.currentTime / _audioPlayer.duration;
        
        // update your UI with timeLeft
        [self.currentlyPlayingCell updateTimeRemaining:timeProgress];
    }
}

#pragma mark -
#pragma mark - Riff Download Delegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_riffData setLength:0];
    [self setTotalBytes:response.expectedContentLength];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_riffData appendData:data];
    [_currentlyPlayingCell updateDownloadIndicatorWithBytes:_riffData.length outOf:_totalBytes];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"%@",[error localizedDescription]);
    [_currentlyPlayingCell finishDownloading:NO];
    [self clearRiff];
    _isDownloading = NO;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_currentlyPlayingCell finishDownloading:YES];
    [self startRiffPlaying:_riffData];
    _isDownloading = NO;
}

#pragma mark -
#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self clearRiff];
}

#pragma mark - ProfilePost Delegate

/*
 Download/play/pause riff track for post corresponding to riffIndex
 */
- (void) playerControlAction:(NSInteger)riffIndex
{
    RYNewsfeedPost *post = _feedItems[riffIndex];
    // if not playing, begin
    if (!_audioPlayer && !self.isDownloading)
    {
        self.currentlyPlayingCell = (RYRiffCell*)[self.riffTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:riffIndex inSection:_riffSection]];
        [self startRiffDownload:post.riff];
        return;
    }
    
    // stop any downloads
    if (self.isDownloading)
        [self clearRiff];
    
    // already playing
    if (_audioPlayer && [self.riffTableView indexPathForCell:self.currentlyPlayingCell].row == riffIndex)
    {
        //currently playing this track, pause it
        if (self.audioPlayer.isPlaying)
        {
            [self.audioPlayer pause];
            [self.currentlyPlayingCell shouldPause:YES];
        }
        else
        {
            [self.audioPlayer play];
            [self.currentlyPlayingCell shouldPause:NO];
        }
    }
    else if (_audioPlayer && _audioPlayer.isPlaying)
    {
        //playing another, switch riff
        [self clearRiff];
        
        self.currentlyPlayingCell = (RYRiffCell*)[self.riffTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:riffIndex inSection:_riffSection]];
        [self startRiffDownload:post.riff];
    }
}

/*
 Upvote post corresponding to riffIndex
 */
- (void) upvoteAction:(NSInteger)riffIndex
{
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:riffIndex];
    [[RYServices sharedInstance] upvote:!post.isUpvoted post:post.postId forDelegate:self];
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

/*
 Follow user for post corresponding to riffIndex
 */
- (void) followAction:(NSInteger)riffIndex
{
    
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
#pragma mark - Upvotes

- (void) upvoteSucceeded:(RYNewsfeedPost *)updatedPost
{
    for (NSInteger postIdx = 0; postIdx < _feedItems.count; postIdx++)
    {
        RYNewsfeedPost *oldPost = _feedItems[postIdx];
        if (oldPost.postId == updatedPost.postId)
        {
            // found the old post, replace it and update UI
            NSMutableArray *mutableFeedItems = [_feedItems mutableCopy];
            [mutableFeedItems replaceObjectAtIndex:postIdx withObject:updatedPost];
            _feedItems = mutableFeedItems;
            [_riffTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:postIdx inSection:self.riffSection]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void) upvoteFailed:(NSString *)reason
{
    UIAlertView *upvoteFailedAlert = [[UIAlertView alloc] initWithTitle:@"Upvote failed" message:reason delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [upvoteFailedAlert show];
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
#warning set correct playback time
    [riffDetails configureForPost:post atPlaybackPosition:0];
    [self presentViewController:riffDetails animated:YES completion:nil];
}

@end
