//
//  RYRiffCreateViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 6/17/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffCreateViewController.h"

// Data Managers
#import "RYMediaEditor.h"

// Data Objects
#import "RYRiff.h"

// Custom UI
#import "RYRiffCreateTableViewCell.h"
#import "BlockAlertView.h"

// Associated View Controller
#import "RYRiffReviewViewController.h"

// Categories
#import "UIViewController+Extras.h"

// Media
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface RYRiffCreateViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, RiffCreateCellDelegate, MergeAudioDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *addTrackButton;
@property (weak, nonatomic) IBOutlet UIButton *playAllButton;

// Data
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSArray *audioPlayers;

@end

@implementation RYRiffCreateViewController

#pragma mark -
#pragma mark - UIViewController Life Cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _audioPlayers = [[NSArray alloc] init];
    
    [_tableView setAllowsSelection:NO];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)recordButtonHit:(id)sender
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    if (!_recorder.isRecording)
    {
        // start recording
        [self prepForRecording];
        
        // play all tracks
        [self playAllButtonHit:nil];
        
        [audioSession setActive:YES error:nil];
        if ([_recorder record])
            [(UIButton*)sender setTitle:@"Recording..." forState:UIControlStateNormal];
    }
    else
    {
        // stop recording
        [_recorder stop];
        [audioSession setActive:NO error:nil];
        [self addTrack:_recorder.url];
        
        [(UIButton*)sender setTitle:@"Record" forState:UIControlStateNormal];
    }
}

- (IBAction)addTrackButtonHit:(id)sender
{
    
}

- (IBAction)playAllButtonHit:(id)sender
{
    for (AVAudioPlayer *audioPlayer in _audioPlayers)
    {
        [audioPlayer setCurrentTime:0];
        [audioPlayer play];
    }
}
- (IBAction)exportButtonHit:(id)sender
{
    [self mergeTracks];
}

#pragma mark -
#pragma mark - Data

- (void) addTrack:(NSURL*)trackURL
{
    NSError *error = nil;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:trackURL error:&error];
    [audioPlayer setEnableRate:YES];
    [audioPlayer prepareToPlay];
    
    _audioPlayers = [_audioPlayers arrayByAddingObject:audioPlayer];
    [self.tableView reloadData];
}

#pragma mark - Recording

/*
 Prepare to record one track (called every time there's a new track)
 */
- (void) prepForRecording
{
    // Set the audio file
    NSURL *outputFileURL = [RYMediaEditor pathForNextTrack];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    _recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
}

#pragma mark -
#pragma mark - RiffCreateCell Delegate


- (void) playTrack:(NSInteger)trackIndex
{
    if (trackIndex < _audioPlayers.count)
    {
        AVAudioPlayer *audioPlayer = _audioPlayers[trackIndex];
        [audioPlayer setCurrentTime:0];
        if ([audioPlayer play])
            NSLog(@"playing");
    }
}

- (void) editTrack:(NSInteger)trackIndex
{
    
}

- (void) deleteTrack:(NSInteger)trackIndex
{
    if (trackIndex < _audioPlayers.count)
    {
        NSMutableArray *players    = [_audioPlayers mutableCopy];
        AVAudioPlayer *audioPlayer = [players objectAtIndex:trackIndex];
        
        NSError *error = nil;
        if ([[NSFileManager defaultManager] removeItemAtURL:audioPlayer.url error:&error])
        {
            // removed track
            [players removeObjectAtIndex:trackIndex];
            _audioPlayers = players;
            [self.tableView reloadData];
        }
    }
}

- (void) changeTrack:(NSInteger)trackIndex volume:(CGFloat)newVolume
{
    if (trackIndex < _audioPlayers.count)
    {
        AVAudioPlayer *audioPlayer = _audioPlayers[trackIndex];
        [audioPlayer setVolume:newVolume];
    }
}

- (void) changeTrack:(NSInteger)trackIndex playbackSpeed:(CGFloat)playbackSpeed
{
    if (trackIndex < _audioPlayers.count)
    {
        AVAudioPlayer *audioPlayer = _audioPlayers[trackIndex];
        [audioPlayer setRate:playbackSpeed];
    }
}

#pragma mark -
#pragma mark - MediaEditor

- (void) mergeTracks
{
    NSMutableArray *urlArray = [[NSMutableArray alloc] initWithCapacity:_audioPlayers.count];
    for (AVAudioPlayer *audioPlayer in _audioPlayers)
    {
        [urlArray addObject:[NSURL fileURLWithPath:[audioPlayer.url path]]];
    }
    [self showHUDWithTitle:@"Exporting"];
    [[RYMediaEditor sharedInstance] setMergeDelegate:self];
    [[RYMediaEditor sharedInstance] mergeAudioData:urlArray];
}

#pragma mark - MergeAudioDelegate

- (void) mergeSucceeded:(NSURL *)newTrackURL
{
    [self hideHUD];
    [self showCheckHUDWithTitle:@"Riff Created" forDuration:1.0f];
    
    [self performBlock:^{
        
        // Create new riff and present riff edit VC
        RYRiff *newRiff = [RYRiff riffWithURL:newTrackURL];
        RYRiffReviewViewController *riffEdit = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"Riff-Review-VC"];
        [riffEdit configureWithRiff:newRiff];
        [self.navigationController pushViewController:riffEdit animated:YES];
        
    } afterDelay:1.0f];
}

- (void) mergeFailed:(NSString *)reason
{
    [self hideHUD];
    UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Action Failed" message:reason delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [failureAlert show];
}

#pragma mark -
#pragma mark - UITableView Data Source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _audioPlayers.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RiffCreateCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RYRiffCreateTableViewCell *trackCell = (RYRiffCreateTableViewCell*)cell;
    [trackCell setTrackIndex:(_audioPlayers.count - indexPath.row - 1)];
    [trackCell setRiffCreateDelegate:self];
}

#pragma mark -
#pragma mark - UITableView Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
