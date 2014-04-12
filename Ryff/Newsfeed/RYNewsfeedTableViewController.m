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

// Media
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface RYNewsfeedTableViewController () <RiffDownloadDelegate>

@property (nonatomic, strong) NSArray *feedItems;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, weak) RYRiffTrackTableViewCell *currentlyPlayingCell;
@property (nonatomic, assign) BOOL isPlaying;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(riffDownloadFinished) name:@"riffDownloadFinished" object:nil];
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
        [riffCell.playPauseButton setImage:maskedImage forState:UIControlStateNormal];
        
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];\
    
    RYNewsfeedPost *post = [_feedItems objectAtIndex:indexPath.section];
    
    if (post.riff && indexPath.row == 0)
    {
        // riff cell
        [self playPauseHitForPost:indexPath.section];
    }
    else
    {
        // open new view controller for chosen user
    }
}

#pragma mark -
#pragma mark - Media Methods

-(void) playPauseHitForPost:(NSUInteger)postIndex
{
    if (!_isPlaying)
    {
        RYNewsfeedPost *post = [_feedItems objectAtIndex:postIndex];
        
        NSString *soundFilePath = post.riff.URL;
        
        NSData *_objectData = [NSData dataWithContentsOfURL:[NSURL URLWithString:soundFilePath]];
        NSError *error;
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:_objectData error:&error];
        _audioPlayer.numberOfLoops = 0;
        _audioPlayer.volume = 1.0f;
        [_audioPlayer prepareToPlay];
        
        if (_audioPlayer == nil)
            NSLog(@"%@", [error description]);
        else
        {
            _isPlaying = YES;
        }
    }
    else
    {
        // should pause
        [_audioPlayer pause];
    }
}

#pragma mark -
#pragma mark - Riff Download Delegate

- (void) riffDownloadStarted
{
    
}
- (void) riffDownloadFinished
{
    if (_isPlaying)
    {
        [_audioPlayer play];
    }
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
