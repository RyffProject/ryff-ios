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

// UI Categories
#import "UIImage+Color.h"

// Data Managers
#import "RYServices.h"

@interface RYRiffStreamingCoreViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) NSTimer *updateTimer;

@end

@implementation RYRiffStreamingCoreViewController

#pragma mark -
#pragma mark - View Controller Lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.riffTableView registerNib:[UINib nibWithNibName:@"RYRiffTrackTableViewCell" bundle:NULL] forCellReuseIdentifier:kRiffTitleCellReuseID];
    [self.riffTableView registerNib:[UINib nibWithNibName:@"RYRiffCellBodyTableViewCell" bundle:NULL] forCellReuseIdentifier:kRiffBodyCellReuseID];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.riffTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.riffTableView setBackgroundColor:[RYStyleSheet backgroundColor]];
    
    [self.view setBackgroundColor:[RYStyleSheet backgroundColor]];
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
    
    NSURL *riffURL = [NSURL URLWithString:riff.URL];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.feedItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:section];
    NSInteger numCells = (post.riff) ? 2 : 1;
    return numCells;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
    if (post.riff && indexPath.row == 0)
    {
        // Title & riff
        cell = [tableView dequeueReusableCellWithIdentifier:kRiffTitleCellReuseID forIndexPath:indexPath];
    }
    else
    {
        // User post: cell body
        cell = [tableView dequeueReusableCellWithIdentifier:kRiffBodyCellReuseID forIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
    if (post.riff && indexPath.row == 0)
    {
        RYRiffTrackTableViewCell *riffTitleCell = (RYRiffTrackTableViewCell*)cell;
        UIImage *maskedImage = [[UIImage imageNamed:@"play.png"] imageWithOverlayColor:[RYStyleSheet baseColor]];
        [riffTitleCell.statusImageView setImage:maskedImage];
        
        [riffTitleCell configureForRiff:post.riff];
    }
    else
    {
        NSAttributedString *attributedText = [RYServices createAttributedTextWithPost:post];
        RYRiffCellBodyTableViewCell *riffBodyCell = (RYRiffCellBodyTableViewCell*)cell;
        [riffBodyCell configureWithAttributedString:attributedText];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0f;
    
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
    if (indexPath.row == 1 || post.riff == NULL)
    {
        CGSize constraint = CGSizeMake(self.view.frame.size.width-kRiffBodyCellPadding, 20000);
        NSAttributedString *mainText = [RYServices createAttributedTextWithPost:post];
        CGRect result = [mainText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        height = MAX(result.size.height+20, height);
    }
    return height;
}

#pragma mark -
#pragma mark - UITableView Delegate

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
        // open new view controller for chosen user
        
    }
}


@end
