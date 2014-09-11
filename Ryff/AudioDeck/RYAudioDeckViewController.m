//
//  RYAudioDeckViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 8/10/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYAudioDeckViewController.h"

#import <MediaPlayer/MediaPlayer.h>

// Data Managers
#import "RYAudioDeckManager.h"
#import "RYStyleSheet.h"

// Data Objects
#import "RYPost.h"

// Custom UI
#import "RYAudioDeckTableViewCell.h"

// Categories
#import "UIImage+Color.h"
#import "UIImage+Thumbnail.h"

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

// Data
@property (nonatomic, assign) BOOL progressSliderTouchActive;

@end

@implementation RYAudioDeckViewController

#pragma mark -
#pragma mark - ViewController Lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[RYStyleSheet audioBackgroundColor]];
    
    [_playButton setTintColor:[RYStyleSheet audioActionColor]];
    [_repostButton setTintColor:[RYStyleSheet audioActionColor]];
    [_nextButton setTintColor:[RYStyleSheet audioActionColor]];
    [_volumeSlider setTintColor:[RYStyleSheet audioActionColor]];
    [_nowPlayingLabel setTextColor:[RYStyleSheet audioActionColor]];
    
    [_controlWrapperView setBackgroundColor:[[RYStyleSheet audioBackgroundColor] colorWithAlphaComponent:0.85f]];
    [_controlWrapperView setClipsToBounds:YES];
    [_controlWrapperView.layer setCornerRadius:10.0f];
    
    
    // long press to move cells
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    [self.tableView addGestureRecognizer:longPress];
    
    // prevent volume hud
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame: _volumeSlider.frame];
    volumeView.autoresizingMask = _volumeSlider.autoresizingMask;
    [volumeView setVolumeThumbImage:[[UIImage imageNamed:@"sliderSmall"] colorImage:[RYStyleSheet audioActionColor]] forState:UIControlStateNormal];
    [volumeView setTintColor:[RYStyleSheet audioActionColor]];
    [volumeView setRouteButtonImage:[[UIImage imageNamed:@"airplayIcon"] colorImage:[RYStyleSheet audioActionColor]] forState:UIControlStateNormal];
    [_controlWrapperView addSubview: volumeView];
    
    [_volumeSlider removeFromSuperview];
    _volumeSlider = nil;
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
    RYAudioDeckManager *audioManager = [RYAudioDeckManager sharedInstance];
    
    if ([audioManager isPlaying])
        [_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    else
        [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    
    if ([audioManager currentlyPlayingPost] || [audioManager riffPlaylist].count > 0)
    {
        // enable audio buttons
        [_playButton setEnabled:YES];
        [_repostButton setEnabled:YES];
        [_nextButton setEnabled:YES];
        [_playbackSlider setUserInteractionEnabled:YES];
        
        [_playbackSlider setTintColor:[RYStyleSheet audioActionColor]];
        if ([audioManager isPlaying])
            [_playbackSlider setThumbImage:[[UIImage imageNamed:@"sliderSeek"] colorImage:[RYStyleSheet audioActionColor]] forState:UIControlStateNormal];
        else
            [_playbackSlider setThumbImage:[[UIImage imageNamed:@"sliderFull"] colorImage:[RYStyleSheet audioActionColor]] forState:UIControlStateNormal];
    }
    else
    {
        // disable audio buttons
        [_playButton setEnabled:NO];
        [_repostButton setEnabled:NO];
        [_nextButton setEnabled:NO];
        [_playbackSlider setValue:0.0f];
        [_playbackSlider setUserInteractionEnabled:NO];
        [_playbackSlider setTintColor:[RYStyleSheet availableActionColor]];
        [_playbackSlider setThumbImage:[[UIImage imageNamed:@"sliderSmall"] colorImage:[RYStyleSheet availableActionColor]] forState:UIControlStateNormal];
    }
    
    if (!_progressSliderTouchActive)
        [_playbackSlider setValue:[audioManager currentPlaybackProgress]];
    
    [_nowPlayingLabel setText:[audioManager currentlyPlayingPost].title];
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
    RYPost *post = [[RYAudioDeckManager sharedInstance] currentlyPlayingPost];
    if (post)
    {
        RYRiffCreateViewController *riffCreateVC = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"RiffCreateVC"];
        [riffCreateVC includeRiffs:@[post.riffURL]];
        [self presentViewController:riffCreateVC animated:YES completion:nil];
    }
}

- (IBAction)nextButtonHit:(id)sender
{
    [[RYAudioDeckManager sharedInstance] skipTrack];
}

- (IBAction)playbackSliderTouchStarted:(id)sender
{
    _progressSliderTouchActive = YES;
}

- (IBAction)playbackSliderTouchUpInside:(id)sender
{
    _progressSliderTouchActive = NO;
    [[RYAudioDeckManager sharedInstance] setPlaybackProgress:_playbackSlider.value];
}

- (IBAction)playbackSliderTouchUpOutside:(id)sender
{
    _progressSliderTouchActive = NO;
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

- (void) post:(RYPost *)post playbackTimeChanged:(CGFloat)time progress:(CGFloat)progress
{
    if (!_progressSliderTouchActive)
        [_playbackSlider setValue:progress animated:YES];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath { return YES; }
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath { return NO; }
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [[RYAudioDeckManager sharedInstance] riffPlaylist].count)
        return YES;
    else
        return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath { return UITableViewCellEditingStyleDelete; }


#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RYAudioDeckTableViewCell *audioCell = (RYAudioDeckTableViewCell *)cell;
    NSArray *playlist = [[RYAudioDeckManager sharedInstance] riffPlaylist];
    RYPost *post;
    if (indexPath.row < playlist.count)
    {
        // riff playlist
        post = [playlist objectAtIndex:indexPath.row];
    }
    else
    {
        NSInteger downloadIdx = indexPath.row-playlist.count;
        post = [[[RYAudioDeckManager sharedInstance] downloadQueue] objectAtIndex:downloadIdx];
    }
    
    [audioCell configureForPost:post trackIdx:(indexPath.row+1)];
    
    if (indexPath == movingIndexPath)
    {
        // currently held with long press gesture
        [audioCell setHidden:YES];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[RYAudioDeckManager sharedInstance] playTrack:NO];
    
    RYPost *post;
    NSArray *playlist = [[RYAudioDeckManager sharedInstance] riffPlaylist];
    if (indexPath.row < playlist.count)
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
    [riffDetails configureForPost:post];
    riffDetails.shouldPreventNavigation = YES;
    [riffDetails addBackButton];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:riffDetails];
    [self presentViewController:navController animated:YES completion:nil];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSArray *playlist = [[RYAudioDeckManager sharedInstance] riffPlaylist];
    if (proposedDestinationIndexPath.row >= playlist.count)
    {
        // only let users drop active rows onto the playlist, not download queue
        proposedDestinationIndexPath = [NSIndexPath indexPathForRow:playlist.count-1 inSection:0];
    }
    
    return proposedDestinationIndexPath;
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[RYAudioDeckManager sharedInstance] movePostFromPlaylistIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        RYPost *postToDelete;
        
        NSArray *playlist = [[RYAudioDeckManager sharedInstance] riffPlaylist];
        NSArray *downloadQueue = [[RYAudioDeckManager sharedInstance] downloadQueue];
        
        if (indexPath.row < playlist.count)
            postToDelete = playlist[indexPath.row];
        else if (indexPath.row - playlist.count < downloadQueue.count)
            postToDelete = downloadQueue[indexPath.row - playlist.count];
        
        [[RYAudioDeckManager sharedInstance] removePostFromPlaylist:postToDelete];
    }
}

#pragma mark -
#pragma mark - Long Press Reorder

static UIView       *snapshot;        // A snapshot of the row user is moving.
static NSIndexPath  *sourceIndexPath; // Initial index path, where gesture begins.
static NSIndexPath  *movingIndexPath; // current moving index path
- (void)longPressGesture:(UILongPressGestureRecognizer *)longPress
{
    CGPoint location = [longPress locationInView:self.tableView];
    movingIndexPath  = [self.tableView indexPathForRowAtPoint:location];
    location         = [self.view convertPoint:location fromView:self.tableView];
    
    NSInteger playlistCount = [[RYAudioDeckManager sharedInstance] riffPlaylist].count;
    
    switch (longPress.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            if (movingIndexPath)
            {
                sourceIndexPath = movingIndexPath;
                
                if (sourceIndexPath.row < playlistCount)
                {
                    // playlist cell, allow moving in playlist
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:movingIndexPath];
                    
                    // Take a snapshot of the selected row using helper method.
                    snapshot = [self customSnapshotFromView:cell];
                    
                    // Add the snapshot as subview, centered at cell's center...
                    __block CGPoint center = [self.view convertPoint:cell.center fromView:self.tableView];
                    snapshot.center = center;
                    snapshot.alpha = 0.0;
                    [self.view insertSubview:snapshot aboveSubview:_tableView];
                    [UIView animateWithDuration:0.25 animations:^{
                        
                        // Offset for gesture location.
                        center.y = location.y;
                        snapshot.center = center;
                        snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                        snapshot.alpha = 0.98;
                        cell.alpha = 0.0;
                        
                    } completion:^(BOOL finished) {
                        cell.hidden = YES;
                    }];
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            if (movingIndexPath && ![movingIndexPath isEqual:sourceIndexPath] && movingIndexPath.row < playlistCount)
            {
                // destination valid, different from source, and in playlist
                [[RYAudioDeckManager sharedInstance] movePostFromPlaylistIndex:sourceIndexPath.row toIndex:movingIndexPath.row];
                
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:movingIndexPath];
                sourceIndexPath = movingIndexPath;
            }
            break;
        }
        default:
        {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                snapshot.center = [self.view convertPoint:cell.center fromView:self.tableView];
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
            } completion:^(BOOL finished) {
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                movingIndexPath = nil;
            }];
            break;
        }
    }
}

#pragma mark - Helper methods

/**
 Returns a customized snapshot of a given view.
 */
- (UIView *)customSnapshotFromView:(UIView *)inputView
{
    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

@end
