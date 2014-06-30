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
#import "RYMediaEditor.h"

// Data Objects
#import "RYRiff.h"

// Custom UI
#import "RYStyleSheet.h"
#import "RYRiffCreateTableViewCell.h"
#import "BlockAlertView.h"


// Categories
#import "UIViewController+Extras.h"

// Media
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface RYRiffCreateViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, RiffCreateCellDelegate, MergeAudioDelegate, RiffDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *imageWrapper;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *addTrackButton;
@property (weak, nonatomic) IBOutlet UIButton *playAllButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

// Data
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSArray *audioPlayers;

@property (nonatomic, assign) BOOL playingAll;

@property (nonatomic, assign) CGFloat riffDuration;

@end

@implementation RYRiffCreateViewController

#pragma mark -
#pragma mark - UIViewController Life Cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _audioPlayers = [[NSArray alloc] init];
    
    [_titleTextField setBackgroundColor:[RYStyleSheet foregroundColor]];
    [_titleTextField setTintColor:[UIColor whiteColor]];
    _titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{NSForegroundColorAttributeName: [UIColor lightTextColor],
                                                                                                              NSFontAttributeName: [UIFont fontWithName:kRegularFont size:24.0f]}];
    [_descriptionTextView setTintColor:[UIColor whiteColor]];
    
    [_imageWrapper setBackgroundColor:[RYStyleSheet backgroundColor]];
    [_recordButton setTintColor:[RYStyleSheet actionColor]];
    [_addTrackButton setTintColor:[RYStyleSheet actionColor]];
    [_playAllButton setTintColor:[RYStyleSheet actionColor]];
    [_backButton setTintColor:[RYStyleSheet actionColor]];
    [_uploadButton setTintColor:[RYStyleSheet actionColor]];
    
    [_tableView setAllowsSelection:NO];
    [_tableView setBackgroundColor:[RYStyleSheet foregroundColor]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageWrapperTapped:)];
    [_imageWrapper addGestureRecognizer:tapGesture];
    
    [self prepForRecording];
}

- (IBAction)backButtonHit:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - GestureRecognizer Delegate

- (void) imageWrapperTapped:(UITapGestureRecognizer*)sender
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)recordButtonHit:(id)sender
{
    [self.view endEditing:YES];
    
    _playingAll = NO;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    if (!_recorder.isRecording)
    {
        // start recording
        [self prepForRecording];
        
        // play all tracks
        [self playAllTracks:YES];
        
        [audioSession setActive:YES error:nil];
        if ([_recorder record])
            [(UIButton*)sender setTintColor:[RYStyleSheet actionHighlightedColor]];
    }
    else
    {
        // stop recording
        [_recorder stop];
        [audioSession setActive:NO error:nil];
        [self addTrack:_recorder.url];
        
        [self playAllTracks:NO];
        
        [(UIButton*)sender setTintColor:[RYStyleSheet actionColor]];
    }
}

- (IBAction)addTrackButtonHit:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)playAllButtonHit:(id)sender
{
    [self.view endEditing:YES];
    
    if (_playingAll)
    {
        [_playAllButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self playAllTracks:NO];
    }
    else
    {
        [_playAllButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [self playAllTracks:YES];
    }
}
- (IBAction)exportButtonHit:(id)sender
{
    [self.view endEditing:YES];
    
    if (_titleTextField.text.length > 0)
        [self mergeTracks];
    else
    {
        UIAlertView *noTitleAlert = [[UIAlertView alloc] initWithTitle:@"Title" message:@"You forgot to name your riff!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [noTitleAlert show];
    }
}

#pragma mark - Action Helpers

/*
 Helper method to either play all (YES) or pause all (NO) tracks
 */
- (void) playAllTracks:(BOOL)playAll
{
    if (playAll)
    {
        // should play
        for (NSInteger i = 0; i < _audioPlayers.count; i++)
        {
            AVAudioPlayer *audioPlayer = _audioPlayers[i];
            [audioPlayer setCurrentTime:0];
            [audioPlayer play];
            
            [[self cellForTrack:i] stylePlaying];
            _playingAll = YES;
        }
    }
    else
    {
        // should pause
        for (NSInteger i = 0; i < _audioPlayers.count; i++)
        {
            AVAudioPlayer *audioPlayer = _audioPlayers[i];
            [audioPlayer setCurrentTime:0];
            [audioPlayer pause];
            
            [[self cellForTrack:i] stylePaused];
            _playingAll = NO;
        }
    }
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
        _playingAll = NO;
        
        AVAudioPlayer *audioPlayer = _audioPlayers[trackIndex];
        if (audioPlayer.playing)
        {
            // is playing, should pause
            [[self cellForTrack:trackIndex] stylePaused];
            [audioPlayer pause];
        }
        else
        {
            // is pause, should play
            [[self cellForTrack:trackIndex] stylePlaying];
            [audioPlayer setCurrentTime:0];
            [audioPlayer play];
        }
    }
}

- (void) deleteTrack:(NSInteger)trackIndex
{
    if (trackIndex < _audioPlayers.count)
    {
        BlockAlertView *blockAlert = [[BlockAlertView alloc] initWithTitle:@"Remove" message:@"Delete track from device?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove Track", nil];
        [blockAlert setDidDismissBlock:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != alertView.cancelButtonIndex)
            {
                // delete file
                NSMutableArray *players    = [_audioPlayers mutableCopy];
                AVAudioPlayer *audioPlayer = [players objectAtIndex:trackIndex];
                
                NSError *error = nil;
                if ([[NSFileManager defaultManager] removeItemAtURL:[audioPlayer.url filePathURL] error:&error])
                {
                    // removed track
                    [_tableView beginUpdates];
                    [players removeObjectAtIndex:trackIndex];
                    _audioPlayers = players;
                    NSInteger cellRow = _audioPlayers.count - trackIndex - 1;
                    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cellRow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView reloadData];
                }
            }
        }];
        [blockAlert show];
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
    CGFloat greatestDuration = 0.f;
    NSMutableArray *urlArray = [[NSMutableArray alloc] initWithCapacity:_audioPlayers.count];
    for (AVAudioPlayer *audioPlayer in _audioPlayers)
    {
        [urlArray addObject:[NSURL fileURLWithPath:[audioPlayer.url path]]];
        greatestDuration = MAX(audioPlayer.duration, greatestDuration);
    }
    _riffDuration = greatestDuration;
    [self showHUDWithTitle:@"Exporting"];
    [[RYMediaEditor sharedInstance] setMergeDelegate:self];
    [[RYMediaEditor sharedInstance] mergeAudioData:urlArray];
}

#pragma mark - MergeAudioDelegate

- (void) mergeSucceeded:(NSURL *)newTrackURL
{
    [self hideHUD];
    [self showCheckHUDWithTitle:@"Riff Created" forDuration:1.0f];
    
    [[RYServices sharedInstance] postRiffWithContent:_descriptionTextView.text title:_titleTextField.text duration:@(_riffDuration) ForDelegate:self];
}

- (void) mergeFailed:(NSString *)reason
{
    [self hideHUD];
    UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Audio Merge Failed" message:reason delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [failureAlert show];
}

#pragma mark -
#pragma mark - RiffDelegate

- (void) riffPostSucceeded
{
    [self hideHUD];
    [self showCheckHUDWithTitle:@"Posted" forDuration:1.5f];
    
    [self performBlock:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    } afterDelay:1.5f];
}

- (void) riffPostFailed
{
    [self hideHUD];
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Something went wrong uploading riff." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [errorAlert show];
}

#pragma mark - 
#pragma mark - UITableView Helpers

- (RYRiffCreateTableViewCell*)cellForTrack:(NSInteger)trackIndex
{
    NSInteger cellRow = _audioPlayers.count - trackIndex - 1;
    return (RYRiffCreateTableViewCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cellRow inSection:0]];
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

#pragma mark -
#pragma mark - UITableView Delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(RYRiffCreateTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL lastInRow = (indexPath.row == _audioPlayers.count-1);
    [cell configureForTrackIndex:(_audioPlayers.count - indexPath.row - 1) forDelegate:self lastRowInSection:lastInRow];}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
