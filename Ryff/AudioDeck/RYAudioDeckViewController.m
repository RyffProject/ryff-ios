//
//  RYAudioDeckViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 8/10/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYAudioDeckViewController.h"

// Data Managers
#import "RYAudioDeckManager.h"
#import "RYStyleSheet.h"

// Data Objects
#import "RYNewsfeedPost.h"

// Custom UI
#import "RYAudioDeckTableViewCell.h"

// Associated View Controllers
#import "RYRiffCreateViewController.h"
#import "RYRiffDetailsViewController.h"

#define kAudioDeckCellReuseID @"audioDeckCell"

@interface RYAudioDeckViewController () <UITableViewDataSource, UITableViewDelegate, AudioDeckDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *controlWrapperView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *nowPlayingLabel;
@property (weak, nonatomic) IBOutlet UISlider *playbackSlider;

@end

@implementation RYAudioDeckViewController

#pragma mark -
#pragma mark - ViewController Lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [_playButton setTintColor:[RYStyleSheet audioActionColor]];
    [_repostButton setTintColor:[RYStyleSheet audioActionColor]];
    [_nextButton setTintColor:[RYStyleSheet audioActionColor]];
    [_volumeSlider setTintColor:[RYStyleSheet audioActionColor]];
    [_playbackSlider setTintColor:[RYStyleSheet audioActionColor]];
    [_nowPlayingLabel setTextColor:[RYStyleSheet audioActionColor]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[RYAudioDeckManager sharedInstance] setDelegate:self];
    [self styleFromAudioDeck];
    [self.tableView reloadData];
}

- (void) styleFromAudioDeck
{
    if ([[RYAudioDeckManager sharedInstance] isPlaying])
        [_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    else
        [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    
    [_volumeSlider setValue:[[RYAudioDeckManager sharedInstance] currentVolume]];
    [_playbackSlider setValue:[[RYAudioDeckManager sharedInstance] currentPlaybackProgress]];
    
    [_nowPlayingLabel setText:[[RYAudioDeckManager sharedInstance] currentlyPlayingPost].riff.title];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)playButtonHit:(id)sender
{
    BOOL shouldPlay = ![[RYAudioDeckManager sharedInstance] isPlaying];
    [[RYAudioDeckManager sharedInstance] playTrack:shouldPlay];
}

- (IBAction)repostButtonHit:(id)sender
{
    RYNewsfeedPost *post = [[RYAudioDeckManager sharedInstance] currentlyPlayingPost];
    RYRiffCreateViewController *riffCreateVC = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"RiffCreateVC"];
    [riffCreateVC includeRiffs:@[post.riff]];
    [self presentViewController:riffCreateVC animated:YES completion:nil];
}

- (IBAction)nextButtonHit:(id)sender
{
    [[RYAudioDeckManager sharedInstance] skipTrack];
}

- (IBAction)volumeSliderChanged:(id)sender
{
    [[RYAudioDeckManager sharedInstance] setVolume:_volumeSlider.value];
}

- (IBAction)playbackSliderChanged:(id)sender
{
    [[RYAudioDeckManager sharedInstance] setPlaybackProgress:_playbackSlider.value];
}

#pragma mark -
#pragma mark - AudioDeck Delegate

- (void) riffPlaylistUpdated
{
    [self.tableView reloadData];
}

- (void) trackChanged
{
    [self styleFromAudioDeck];
}

- (void) post:(RYNewsfeedPost *)post playbackTimeChanged:(CGFloat)time progress:(CGFloat)progress
{
    [_playbackSlider setValue:progress animated:YES];
}

- (void) post:(RYNewsfeedPost *)post downloadProgressChanged:(CGFloat)progress
{
    NSArray *playlist = [[RYAudioDeckManager sharedInstance] riffPlaylist];
    NSInteger tableRow = playlist.count - 1 + [[RYAudioDeckManager sharedInstance] idxOfDownload:post];
    RYAudioDeckTableViewCell *audioCell = (RYAudioDeckTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tableRow inSection:0]];
    [audioCell updateDownloadProgress:progress];
}

#pragma mark -
#pragma mark - TableView Data Source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[RYAudioDeckManager sharedInstance] riffPlaylist].count + [[RYAudioDeckManager sharedInstance] downloadQueue].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_tableView dequeueReusableCellWithIdentifier:kAudioDeckCellReuseID];
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return 0.01f; }
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return 0.01f; }

#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RYAudioDeckTableViewCell *audioCell = (RYAudioDeckTableViewCell *)cell;
    NSArray *playlist = [[RYAudioDeckManager sharedInstance] riffPlaylist];
    if (indexPath.row < playlist.count)
    {
        // riff playlist
        RYNewsfeedPost *post = [playlist objectAtIndex:indexPath.row];
        [audioCell configureForPost:post trackIdx:indexPath.row];
        [audioCell styleDownloading:NO];
    }
    else
    {
        // download queue
        NSInteger downloadIdx = indexPath.row-playlist.count;
        RYNewsfeedPost *post = [[[RYAudioDeckManager sharedInstance] downloadQueue] objectAtIndex:downloadIdx];
        [audioCell configureForPost:post trackIdx:-1];
        [audioCell styleDownloading:YES];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[RYAudioDeckManager sharedInstance] playTrack:NO];
    
    RYNewsfeedPost *post;
    NSArray *playlist = [[RYAudioDeckManager sharedInstance] riffPlaylist];
    if (indexPath.row <= playlist.count)
    {
        // riff playlist
        post = [playlist objectAtIndex:indexPath.row];
    }
    else
    {
        // riff download
        NSInteger downloadIdx = indexPath.row-playlist.count;
        post = [[[RYAudioDeckManager sharedInstance] downloadQueue] objectAtIndex:downloadIdx];
    }
    
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYRiffDetailsViewController *riffDetails = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"riffDetails"];
    [riffDetails configureForPost:post familyType:CHILDREN];
    [riffDetails addBackButton];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:riffDetails];
    [self presentViewController:navController animated:YES completion:nil];
}

@end
