//
//  RYRiffCreateViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 6/17/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffCreateViewController.h"

// Data Managers
#import "RYServices.h"

// Custom UI
#import "RYRiffCreateTableViewCell.h"
#import "BlockAlertView.h"

// Media
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface RYRiffCreateViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, RiffCreateCellDelegate>

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
    [self prepForRecording];
    
    [_tableView setAllowsSelection:NO];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)recordButtonHit:(id)sender
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    if (!_recorder.recording)
    {
        // start recording
        [audioSession setActive:YES error:nil];
        [_recorder record];
        
        [(UIButton*)sender setTitle:@"Recording..." forState:UIControlStateNormal];
    }
    else
    {
        // stop recording
        [_recorder stop];
        [audioSession setActive:NO error:nil];
        NSData *trackData = [NSData dataWithContentsOfFile:[[RYServices pathForRiff] path]];
        [self addTrack:trackData];
        
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

#pragma mark -
#pragma mark - Data

- (void) addTrack:(NSData*)newTrack
{
    NSError *error = nil;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:newTrack error:&error];
    [audioPlayer setEnableRate:YES];
    [audioPlayer prepareToPlay];
    
    _audioPlayers = [_audioPlayers arrayByAddingObject:audioPlayer];
    [self.tableView reloadData];
}

#pragma mark - Recording

- (void) prepForRecording
{
    // Set the audio file
    NSURL *outputFileURL = [RYServices pathForRiff];
    
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
        [audioPlayer play];
    }
}

- (void) editTrack:(NSInteger)trackIndex
{
    
}

- (void) deleteTrack:(NSInteger)trackIndex
{
    if (trackIndex < _audioPlayers.count)
    {
        NSMutableArray *players = [_audioPlayers mutableCopy];
        [players removeObjectAtIndex:trackIndex];
        _audioPlayers = players;
        [self.tableView reloadData];
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
