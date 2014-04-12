//
//  RYNewsfeedTableViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNewsfeedTableViewController.h"

// Data Managers
#import "RYServices.h"

// Data Objects
#import "RYNewsfeedPost.h"
#import "RYRiff.h"
#import "RYUser.h"

// Custom UI
#import "RYRiffTrackTableViewCell.h"
#import "RYStyleSheet.h"
#import "RYRiffTrackTableViewCell.h"
#import "UIViewController+Extras.h"

// Media
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface RYNewsfeedTableViewController ()

@property (nonatomic, strong) NSArray *feedItems;

// Audio
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSMutableData *riffData;
@property (nonatomic, strong) NSURLConnection *riffConnection;
@property (nonatomic, assign) CGFloat totalBytes;
@property (nonatomic, weak) RYRiffTrackTableViewCell *currentlyPlayingCell;
@property (nonatomic, assign) BOOL isDownloading, isPlaying;

@end

@implementation RYNewsfeedTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up test data
    RYUser *patrick = [RYUser patrick];
    RYRiff *nextgirl = [[RYRiff alloc] initWithTitle:@"Next Girl" length:180 url:@"http://danielawrites.files.wordpress.com/2010/05/the-black-keys-next-girl.mp3"];
    RYNewsfeedPost *testPost = [[RYNewsfeedPost alloc] initWithUsername:patrick.username mainText:@"A new song we've been working on..." riff:nextgirl];
    
    _feedItems = @[testPost];
    _isPlaying = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _feedItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RYNewsfeedPost *post = [_feedItems objectAtIndex:section];
    NSInteger numCells = (post.riff) ? 2 : 1;
    return numCells;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    RYNewsfeedPost *post = [_feedItems objectAtIndex:indexPath.section];
    if (post.riff && indexPath.row == 0)
    {
        RYRiffTrackTableViewCell *riffCell = [tableView dequeueReusableCellWithIdentifier:@"RiffCell" forIndexPath:indexPath];
        cell = riffCell;
    }
    else
    {
        // user post
        cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RYNewsfeedPost *post = [_feedItems objectAtIndex:indexPath.section];
    if (post.riff && indexPath.row == 0)
    {
        RYRiffTrackTableViewCell *riffCell = (RYRiffTrackTableViewCell*)cell;
        UIImage *maskedImage = [RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"play.png"];
        [riffCell.statusImageView setImage:maskedImage];
        
        [riffCell configureForRiff:post.riff];
    }
    else
    {
        NSAttributedString *attributedText = [self createAttributedTextWithPost:post];
        
        [cell.textLabel setAttributedText:attributedText];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0f;
    
    RYNewsfeedPost *post = [_feedItems objectAtIndex:indexPath.section];
    if (indexPath.row == 1 || post.riff == NULL)
    {
        CGSize constraint = CGSizeMake(self.view.frame.size.width, 20000);
        NSAttributedString *mainText = [self createAttributedTextWithPost:post];
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
    
    RYNewsfeedPost *post = [_feedItems objectAtIndex:indexPath.section];
    
    if (post.riff && indexPath.row == 0)
    {
        _currentlyPlayingCell = (RYRiffTrackTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        // riff cell
        if (!_isPlaying)
        {
            _isPlaying = YES;
            [self startRiffDownload:post.riff];
        }
        else
        {
            // already playing
            if ([tableView indexPathForCell:_currentlyPlayingCell].section == indexPath.section)
            {
                if (_isDownloading)
                    // stop download
                    [self clearRiffDownloading];
                else
                {
                    //currently playing this track, pause it
                    if (_audioPlayer.isPlaying)
                    {
                        [_audioPlayer pause];
                        [_currentlyPlayingCell shouldPause:YES];
                    }
                    else
                    {
                        [_audioPlayer play];
                        [_currentlyPlayingCell shouldPause:NO];
                    }
                }
            }
            else
            {
                //playing another, switch riff
                [self clearRiffDownloading];
                
                [self startRiffDownload:post.riff];
            }
        }
    }
    else
    {
        // open new view controller for chosen user
        
    }
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
    if (_isPlaying)
    {
        NSError *error;
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:riffData error:&error];
        _audioPlayer.numberOfLoops = 0;
        _audioPlayer.volume = 1.0f;
        [_audioPlayer prepareToPlay];
        
        if (_audioPlayer == nil)
            NSLog(@"%@", [error description]);
        else
        {
            [_audioPlayer play];
        }
    }
}

- (void) clearRiffDownloading
{
    [_currentlyPlayingCell clearAudio];
    _currentlyPlayingCell = nil;
    _riffData = nil;
    _riffConnection = nil;
    _audioPlayer = nil;
    _isPlaying = NO;
    _isDownloading = NO;
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
    [_currentlyPlayingCell finishDownloading:NO];
    [self clearRiffDownloading];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_currentlyPlayingCell finishDownloading:YES];
    [self startRiffPlaying:_riffData];
    _isDownloading = NO;
}

#pragma mark -
#pragma mark - Extras
- (NSAttributedString *)createAttributedTextWithPost:(RYNewsfeedPost *)post
{
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [RYStyleSheet boldFont], NSFontAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              [RYStyleSheet baseFont], NSFontAttributeName, nil];
    const NSRange range = NSMakeRange(0,post.username.length);
    
    // Create the attributed string (text + attributes)
    NSString *fullText = [NSString stringWithFormat:@"%@ %@",post.username,post.mainText];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText
                                                                                       attributes:subAttrs];
    [attributedText setAttributes:attrs range:range];
    return attributedText;
}

@end
