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
#import "RYDataManager.h"

// Data Objects
#import "RYRiff.h"

// Custom UI
#import "RYStyleSheet.h"
#import "RYRiffCreateTableViewCell.h"
#import "RYTrackDownloadTableViewCell.h"
#import "BlockAlertView.h"


// Categories
#import "UIViewController+Extras.h"

// Media
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define kDownloadSection (_audioPlayers && _audioPlayers.count > 0) ? 1 : 0
#define kTrackSection 0

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
@property (nonatomic, strong) NSMutableArray *audioPlayers;
@property (nonatomic, strong) NSMutableArray *downloadingRiffs;

@property (nonatomic, assign) BOOL playingAll;
@property (nonatomic, assign) BOOL safeToUpdateTable;

@property (nonatomic, assign) CGFloat riffDuration;

@end

@implementation RYRiffCreateViewController

/*
 Start this view controller with these tracks already populating _audioPlayers. This is used when reposting riffs.
 PARAMETERS:
 -arrayOfRiffs: array of riffs to include
 */
- (void) includeRiffs:(NSArray*)arrayOfRiffs
{
    _downloadingRiffs = _downloadingRiffs ? _downloadingRiffs : [[NSMutableArray alloc] initWithCapacity:arrayOfRiffs.count];
    for (RYRiff *riff in arrayOfRiffs)
    {
        // have to download track
        [_downloadingRiffs addObject:riff];
        [[RYDataManager sharedInstance] saveRiffAt:riff.URL toLocalURL:[RYDataManager urlForNextTrack] forDelegate:self];
    }
    [_tableView reloadData];
}

#pragma mark -
#pragma mark - UIViewController Life Cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _audioPlayers      = [[NSMutableArray alloc] init];
    _safeToUpdateTable = YES;
    
    [_titleTextField setBackgroundColor:[RYStyleSheet tabBarColor]];
    [_titleTextField setTintColor:[UIColor whiteColor]];
    _titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{NSForegroundColorAttributeName: [UIColor lightTextColor],
                                                                                                              NSFontAttributeName: [UIFont fontWithName:kRegularFont size:24.0f]}];
    [_descriptionTextView setTintColor:[UIColor whiteColor]];
    
    [_imageWrapper setBackgroundColor:[RYStyleSheet tabBarColor]];
    [_recordButton setTintColor:[RYStyleSheet audioActionColor]];
    [_addTrackButton setTintColor:[RYStyleSheet audioActionColor]];
    [_playAllButton setTintColor:[RYStyleSheet audioActionColor]];
    [_backButton setTintColor:[RYStyleSheet audioActionColor]];
    [_uploadButton setTintColor:[RYStyleSheet audioActionColor]];
    
    [_tableView setAllowsSelection:NO];
    [_tableView setBackgroundColor:[RYStyleSheet tabBarColor]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UITapGestureRecognizer *imageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageWrapperTapped:)];
    [_imageWrapper addGestureRecognizer:imageTapGesture];
    UITapGestureRecognizer *tableTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTapped:)];
    [_tableView addGestureRecognizer:tableTapGesture];
    
    [self prepForRecording];
}

- (void) viewWillAppear:(BOOL)animated
{
    [_tableView reloadData];
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

- (void) tableViewTapped:(UITapGestureRecognizer*)sender
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
            [(UIButton*)sender setTintColor:[RYStyleSheet audioActionHighlightedColor]];
    }
    else
    {
        // stop recording
        [_recorder stop];
        [audioSession setActive:NO error:nil];
        [self addTrack:_recorder.url];
        
        [self playAllTracks:NO];
        
        [(UIButton*)sender setTintColor:[RYStyleSheet audioActionColor]];
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
    
    if (_audioPlayers.count > 0)
        [self mergeTracks];
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

/*
 Helper method to add a track both to the data model and to the table view
 */
- (void) addTrack:(NSURL*)trackURL
{
    //NSURL *fileUrl = [trackURL fileReferenceURL]; // for local file
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:trackURL error:NULL];
    [audioPlayer setEnableRate:YES];
    [audioPlayer prepareToPlay];
    
    if (audioPlayer && _safeToUpdateTable)
    {
        _safeToUpdateTable = NO;
        [_tableView beginUpdates];
        [_audioPlayers addObject:audioPlayer];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:kTrackSection]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_tableView endUpdates];
        _safeToUpdateTable = YES;
    }
}

#pragma mark - Recording

/*
 Prepare to record one track (called every time there's a new track)
 */
- (void) prepForRecording
{
    // Set the audio file
    NSURL *outputFileURL = [RYDataManager urlForNextTrack];
    
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


- (void) playTrack:(AVAudioPlayer *)player
{
    if ([_audioPlayers containsObject:player])
    {
        _playingAll = NO;
        NSInteger trackIndex = [_audioPlayers indexOfObject:player];
        
        if (player.playing)
        {
            // is playing, should pause
            [[self cellForTrack:trackIndex] stylePaused];
            [player pause];
        }
        else
        {
            // is pause, should play
            [[self cellForTrack:trackIndex] stylePlaying];
            [player setCurrentTime:0];
            [player play];
        }
    }
}

- (void) deleteTrack:(AVAudioPlayer *)player
{
    if ([_audioPlayers containsObject:player])
    {
        BlockAlertView *blockAlert = [[BlockAlertView alloc] initWithTitle:@"Remove" message:@"Delete track from device?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove Track", nil];
        [blockAlert setDidDismissBlock:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != alertView.cancelButtonIndex)
            {
                // delete file
                NSMutableArray *players    = [_audioPlayers mutableCopy];
                
                if (_safeToUpdateTable && [[NSFileManager defaultManager] removeItemAtURL:[player.url filePathURL] error:NULL])
                {
                    // removed track
                    _safeToUpdateTable = NO;
                    [_tableView beginUpdates];
                    NSInteger trackIndex = [_audioPlayers indexOfObject:player];
                    NSInteger cellRow    = _audioPlayers.count - trackIndex - 1;
                    [players removeObjectAtIndex:trackIndex];
                    _audioPlayers        = players;
                    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cellRow inSection:kTrackSection]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [_tableView endUpdates];
                    _safeToUpdateTable   = YES;
                }
            }
        }];
        [blockAlert show];
    }
}

- (void) changeTrack:(AVAudioPlayer *)player volume:(CGFloat)newVolume
{
    if ([_audioPlayers containsObject:player])
        [player setVolume:newVolume];
}

- (void) changeTrack:(AVAudioPlayer *)player playbackSpeed:(CGFloat)playbackSpeed
{
    if ([_audioPlayers containsObject:player])
        [player setRate:playbackSpeed];
}

#pragma mark -
#pragma mark - TrackDownloadDelegate (DataManager)

- (void) track:(NSURL *)trackURL DownloadProgressed:(CGFloat)progress
{
    // change cell's progress view
    RYTrackDownloadTableViewCell *trackCell = (RYTrackDownloadTableViewCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self indexForDownloadingURL:trackURL] inSection:kDownloadSection]];
    [trackCell.progressView setProgress:progress];
}

- (void) track:(NSURL *)trackURL DownloadFailed:(NSString *)reason
{
    // show alert and remove downloading cell
    NSInteger trackIdx = [self indexForDownloadingURL:trackURL];
    _safeToUpdateTable = NO;
    [_tableView beginUpdates];
    
    [_downloadingRiffs removeObjectAtIndex:trackIdx];
    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:trackIdx inSection:kDownloadSection]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [_tableView endUpdates];
    _safeToUpdateTable = YES;
    
    UIAlertView *downloadFailedAlert = [[UIAlertView alloc] initWithTitle:@"Download Failed" message:@"Please check network settings" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [downloadFailedAlert show];
}

- (void) track:(NSURL *)trackURL FinishedDownloading:(NSURL *)localURL
{
    NSInteger trackIdx = [self indexForDownloadingURL:trackURL];
    
    if (_safeToUpdateTable)
    {
        _safeToUpdateTable = NO;
        [_tableView beginUpdates];
        
        [_downloadingRiffs removeObjectAtIndex:trackIdx];
        [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:trackIdx inSection:kDownloadSection]] withRowAnimation:UITableViewRowAnimationAutomatic];

        [_tableView endUpdates];
        _safeToUpdateTable = YES;
    }
    [self addTrack:localURL];
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
    
    [[RYServices sharedInstance] postRiffWithContent:_descriptionTextView.text title:_titleTextField.text duration:@(_riffDuration) parentIDs:nil ForDelegate:self];
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

/*
 Helper method to get a relevant riff downloading cell for a given URL
 */
- (NSInteger)indexForDownloadingURL:(NSURL*)downloadingURL
{
    NSInteger index = -1;
    for (NSInteger trackIdx = 0; trackIdx < _downloadingRiffs.count; trackIdx++)
    {
        RYRiff *riff = _downloadingRiffs[trackIdx];
        if ([riff.URL isEqual:downloadingURL])
        {
            // found the right index
            index = trackIdx;
            break;
        }
    }
    return index;
}

/*
 Helper method to get a relevant track cell for a given track index in _audioPlayers.
 */
- (RYRiffCreateTableViewCell*)cellForTrack:(NSInteger)trackIndex
{
    RYRiffCreateTableViewCell *cell;
    if (trackIndex < _audioPlayers.count)
    {
        NSInteger cellRow = _audioPlayers.count - trackIndex - 1;
        cell = (RYRiffCreateTableViewCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cellRow inSection:kTrackSection]];
    }
    return cell;
}

#pragma mark -
#pragma mark - UITableView Data Source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return _downloadingRiffs ? 1 : 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows;
    if (section == kDownloadSection)
        numRows = _downloadingRiffs.count;
    else
        numRows = _audioPlayers.count;
    return numRows;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == kDownloadSection)
        cell = [tableView dequeueReusableCellWithIdentifier:@"TrackDownloadCell" forIndexPath:indexPath];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:@"RiffCreateCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

#pragma mark -
#pragma mark - UITableView Delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kDownloadSection)
    {
        // downloading row
        RYRiff *relevantRiff = _downloadingRiffs[indexPath.row];
        [((RYTrackDownloadTableViewCell*)cell).descriptionLabel setText:relevantRiff.title];
    }
    else
    {
        // track cell
        RYRiffCreateTableViewCell *trackCell = (RYRiffCreateTableViewCell*)cell;
        BOOL lastInRow = (indexPath.row == _audioPlayers.count-1);
        AVAudioPlayer *associatedPlayer = _audioPlayers[(_audioPlayers.count - indexPath.row - 1)];
        [trackCell configureForAudioPlayer:associatedPlayer forDelegate:self lastRowInSection:lastInRow];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
