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

// UI Categories
#import "UIImage+Color.h"

// Data Managers
#import "RYServices.h"

@interface RYRiffStreamingCoreViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, RYRiffDetailsCellDelegate, UpvoteDelegate>

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
    
    [self.riffTableView registerNib:[UINib nibWithNibName:@"RYRiffTrackTableViewCell" bundle:NULL] forCellReuseIdentifier:kRiffTitleCellReuseID];
    [self.riffTableView registerNib:[UINib nibWithNibName:@"RyRiffDetailsTableViewCell" bundle:NULL] forCellReuseIdentifier:kRiffDetailsCellReuseID];
    [self.riffTableView registerNib:[UINib nibWithNibName:@"RYRiffCellBodyTableViewCell" bundle:NULL] forCellReuseIdentifier:kRiffBodyCellReuseID];
    
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
    if (!_isPlaying)
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
        
        _updateTimer= [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             target:self
                                                           selector:@selector(updateTimeLeft)
                                                           userInfo:nil
                                                            repeats:YES];
        _isPlaying = YES;
    }
}

- (void) clearRiff
{
    [_updateTimer invalidate];
    _updateTimer = nil;
    [_currentlyPlayingCell clearAudio];
    _currentlyPlayingCell = nil;
    [_audioPlayer stop];
    _audioPlayer = nil;
    _totalBytes = 0;
    _riffData = nil;
    _riffConnection = nil;
    _audioPlayer = nil;
    _isPlaying = NO;
    _isDownloading = NO;
}

#pragma mark -
#pragma mark - Timer UI Update

- (void)updateTimeLeft
{
    NSTimeInterval timeLeft = _audioPlayer.duration - _audioPlayer.currentTime;
    
    // update your UI with timeLeft
    [self.currentlyPlayingCell updateTimeRemaining:timeLeft];
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

#pragma mark -
#pragma mark - RYRiffDetailsCellDelegate
// actions by details cell

/*
 Upvote button hit. Should apply upvote to the relevant riff.
 */
- (void) upvoteHit:(NSInteger)riffIndex
{
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:riffIndex];
    [[RYServices sharedInstance] upvote:!post.isUpvoted post:post.postId forDelegate:self];
}

/*
 Repost button hit. Should open a new RYRiffCreateVC with the relevant riff.
 */
- (void) repostHit:(NSInteger)riffIndex
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
 Delete post button hit. Should have services do so
 */
- (void) deleteHit:(NSInteger)riffIndex
{
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:riffIndex];
    BlockAlertView *deleteAlert = [[BlockAlertView alloc] initWithTitle:@"Delete Riff?" message:[NSString stringWithFormat:@"Are you sure you wish to delete %@?",post.riff.title] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [deleteAlert setDidDismissBlock:^(BlockAlertView *alertView, NSInteger buttonIndex) {
        
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            // delete post
            NSMutableArray *mutableFeedItems = [_feedItems mutableCopy];
            [mutableFeedItems removeObjectAtIndex:riffIndex];
            [_riffTableView beginUpdates];
            _feedItems = mutableFeedItems;
            [_riffTableView deleteSections:[NSIndexSet indexSetWithIndex:riffIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            _openRiffDetailsSection = -1;
            [_riffTableView endUpdates];
            [[RYServices sharedInstance] deletePost:post];
        }
    }];
    [deleteAlert show];
}

- (void) longPress:(NSInteger)riffIndex
{
    // Should open that section with more options
    [self openRiffDetailsForSection:riffIndex];
}

#pragma mark - RiffCell Actions

/*
 Open/close details for riff at given index. Will close the currently open one (_openRiffDetailsSection), and open the one at riffIndex if that wasn't just open
 */
- (void) openRiffDetailsForSection:(NSInteger)riffIndex
{
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:riffIndex];
    
    [self.riffTableView beginUpdates];
    
    NSInteger oldOpen = _openRiffDetailsSection;
    
    if (_openRiffDetailsSection >= 0)
    {
        RYNewsfeedPost *oldPost = [self.feedItems objectAtIndex:_openRiffDetailsSection];
        NSInteger rowForBody = (oldPost.riff) ? 2 : 1;
        
        // should close the currently open riff
        [self.riffTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowForBody-1 inSection:_openRiffDetailsSection]] withRowAnimation:UITableViewRowAnimationMiddle];
        _openRiffDetailsSection = -1;
    }
    
    if (oldOpen != riffIndex)
    {
        // riff selected wasn't already open, should open it
        NSInteger rowForBody = (post.riff) ? 2 : 1;
        
        // insert new row
        _openRiffDetailsSection = riffIndex;
        [self.riffTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowForBody-1 inSection:riffIndex]] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
    [self.riffTableView endUpdates];
}

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
            [_riffTableView reloadSections:[NSIndexSet indexSetWithIndex:postIdx] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    return self.feedItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:section];
    NSInteger numCells = (post.riff) ? 2 : 1;
    
    if (section == _openRiffDetailsSection)
    {
        // riff details are open, should have extra row
        numCells++;
    }
    
    return numCells;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
    NSInteger riffAdjust = (post.riff) ? 1 : 0;
    
    if (post.riff && indexPath.row == 0)
    {
        // Title & riff
        cell = [tableView dequeueReusableCellWithIdentifier:kRiffTitleCellReuseID forIndexPath:indexPath];
    }
    else
    {
        if (indexPath.section == _openRiffDetailsSection && indexPath.row == riffAdjust)
        {
            // riff details
            cell = [tableView dequeueReusableCellWithIdentifier:kRiffDetailsCellReuseID forIndexPath:indexPath];
        }
        else
        {
            // User post: cell body
            cell = [tableView dequeueReusableCellWithIdentifier:kRiffBodyCellReuseID forIndexPath:indexPath];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
    NSInteger riffAdjust = (post.riff) ? 1 : 0;
    
    if (post.riff && indexPath.row == 0)
    {
        // title cell
        RYRiffTrackTableViewCell *riffTitleCell = (RYRiffTrackTableViewCell*)cell;
        [riffTitleCell configureForPost:post];
    }
    else if (indexPath.section == _openRiffDetailsSection && indexPath.row == riffAdjust)
    {
        // riff details cell
        RyRiffDetailsTableViewCell *riffDetailsCell = (RyRiffDetailsTableViewCell*)cell;
        [riffDetailsCell configureForPost:post index:indexPath.section withDelegate:self];
    }
    else
    {
        // riff body cell
        NSAttributedString *attributedText = [RYServices createAttributedTextWithPost:post];
        RYRiffCellBodyTableViewCell *riffBodyCell = (RYRiffCellBodyTableViewCell*)cell;
        [riffBodyCell configureWithAttributedString:attributedText index:indexPath.section delegate:self];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
    
    CGFloat height = (indexPath.row == 0 && post.riff) ? 50.0f : 44.0f;
    
    NSInteger bodyRow = (post.riff) ? 1 : 0;
    if (indexPath.section == _openRiffDetailsSection)
        bodyRow++;
    
    if (indexPath.row == bodyRow)
    {
        CGSize constraint = CGSizeMake(self.view.frame.size.width-kRiffBodyCellPadding, 20000);
        NSAttributedString *mainText = [RYServices createAttributedTextWithPost:post];
        CGRect result = [mainText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        height = MAX(result.size.height+20, height);
    }
    
    return height;
}

#pragma mark -
#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
    
    // Riff row
    if (post.riff && indexPath.row == 0)
    {
        // if not playing, begin
        if (!self.isPlaying && !self.isDownloading)
        {
            self.currentlyPlayingCell = (RYRiffTrackTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            [self startRiffDownload:post.riff];
            return;
        }
        
        // stop any downloads
        if (self.isDownloading)
            [self clearRiff];
        
        // already playing
        if (self.isPlaying && [tableView indexPathForCell:self.currentlyPlayingCell].section == indexPath.section)
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
        else if (self.isPlaying)
        {
            //playing another, switch riff
            [self clearRiff];
            
            self.currentlyPlayingCell = (RYRiffTrackTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            [self startRiffDownload:post.riff];
        }
    }
    else
    {
        // open riff details VC
        [self openRiffDetailsForSection:indexPath.section];
    }
}


@end
