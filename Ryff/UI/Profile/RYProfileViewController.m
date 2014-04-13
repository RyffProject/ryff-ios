//
//  RYProfileViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYProfileViewController.h"

// Data Managers
#import "RYServices.h"

// Data Objects
#import "RYUser.h"
#import "RYNewsfeedPost.h"

// Custom UI
#import "RYStyleSheet.h"
#import "RYRiffTrackTableViewCell.h"
#import "BlockAlertView.h"
#import "RYTextBlockTableViewCell.h"
#import "UIViewController+Extras.h"

enum VisualStatus : NSUInteger {
    ABOUT = 1,
    ACTIVITY = 2,
    RECORD = 3
};

@interface RYProfileViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate, RiffDelegate, POSTDelegate>

@property (nonatomic, assign) enum VisualStatus visualStatus;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong) NSString *riffContent;

@end

@implementation RYProfileViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self prepForRecording];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self configureForUser:_user];
    [self setVisualStatus:ABOUT];
    [_tableView reloadData];
    
    [_recentActivityButton setImage:[RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"newsfeed"] forState:UIControlStateNormal];
    [_addButton setImage:[RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"plus"] forState:UIControlStateNormal];
    [_aboutButton setImage:[RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"user"] forState:UIControlStateNormal];
    
    UITapGestureRecognizer *backgroundTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.view addGestureRecognizer:backgroundTap];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self clearRiffDownloading];
    
    // Remove Gestures
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }
}

- (void) configureForUser:(RYUser *)user
{
    // Profile picture
    [_profileImageView setImage:user.profileImage];
    [_profileImageView.layer setCornerRadius:50.0f];
    [_profileImageView setClipsToBounds:YES];
    
    // Edit button
    if ([user.username isEqualToString:[RYServices loggedInUser].username])
    {
        
    }
    else
    {
        [_editButton removeFromSuperview];
    }
    
    // Display name
    [_nameText setText:user.firstName];
    
    
    // prep activity
    [self setFeedItems:user.activity];
}

#pragma mark - TextFields

- (void)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark - Button Actions

- (IBAction)editHit:(id)sender
{
    
}

- (IBAction)activityHit:(id)sender
{
    [self setVisualStatus:ACTIVITY];
    [self clearRiffDownloading];
    [_tableView reloadData];
    
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        [[RYServices sharedInstance] getMyPostsForDelegate:self];
    });
}

- (IBAction)addHit:(id)sender
{
    [self setVisualStatus:RECORD];
    [self clearRiffDownloading];
    [_tableView reloadData];
}

- (IBAction)aboutHit:(id)sender
{
    [self setVisualStatus:ABOUT];
    [self clearRiffDownloading];
    [_tableView reloadData];
}

#pragma mark -
#pragma mark - Recordings

- (void) prepForRecording
{
    // Should disable stuff first
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"riff.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
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

- (void) recordButtonHit
{
    if (!_recorder.recording)
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [_recorder record];
        _isRecording = true;
    }
    else
    {
        [_recorder stop];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        _isRecording = false;
        
        BlockAlertView *recordConfirmation = [[BlockAlertView alloc] initWithTitle:@"Got it." message:@"Would you like to post this riff?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Post", nil];
        [recordConfirmation setClickedButtonBlock:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != alertView.cancelButtonIndex)
            {
                [self processRiff];
            }
        }];
        [recordConfirmation show];
    }
    
    [self.tableView reloadData];
}

- (void) processRiff
{
    [[RYServices sharedInstance] postRiffWithContent:_riffContent title:@"riff" duration:0 ForDelegate:self];
}

- (void) cleanupRiff
{
    NSURL *outputFileURL = [RYServices pathForRiff];
    NSError *error;
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:[outputFileURL path]]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[outputFileURL path] error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
}

#pragma mark -
#pragma mark - POSTDelegate
//specifically for fetching my posts
- (void) connectionFailed
{
    
}
- (void) postFailed:(NSString*)reason
{
    
}
- (void) postSucceeded:(id)response
{
    NSDictionary *responseDict = response;
    NSArray *posts = [responseDict objectForKey:@"posts"];
    
    NSMutableArray *myPosts = [[NSMutableArray alloc] init];
    
    for (NSDictionary *postDict in posts)
    {
        RYNewsfeedPost *post = [RYNewsfeedPost newsfeedPostWithDict:postDict];
        [myPosts addObject:post];
    }
    [self setFeedItems:myPosts];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Riff Post Delegate

- (void) riffPostSucceeded
{
    [self cleanupRiff];
    [self showCheckHUDWithTitle:@"Posted!" forDuration:1.0f];
}
- (void) riffPostFailed
{
    [self cleanupRiff];
    BlockAlertView *failureAlert = [[BlockAlertView alloc] initWithTitle:@"Couldn't Post" message:@"Something went wrong while processing that request" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [failureAlert show];
}

#pragma mark -
#pragma mark - UITableView Data Source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = 0;
    
    if (_visualStatus == ABOUT)
    {
        sectionCount = 2;
    }
    else if (_visualStatus == ACTIVITY)
    {
        sectionCount = self.feedItems.count;
    }
    else if (_visualStatus == RECORD)
    {
        sectionCount = 1;
    }
    
    return sectionCount;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    
    if (_visualStatus == ABOUT)
    {
        switch (section) {
            case 0:
            case 1:
                rowCount = 1;
                break;
            default:
                break;
        }
    }
    else if (_visualStatus == ACTIVITY)
    {
        RYNewsfeedPost *post = [self.feedItems objectAtIndex:section];
        rowCount = (post.riff) ? 2 : 1;
    }
    else if (_visualStatus == RECORD)
    {
        rowCount = 2;
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    [cell setBounds:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    if (_visualStatus == ABOUT)
    {
        if (indexPath.section == 0)
        {
            //biography
            cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
        }
    }
    else if (_visualStatus == ACTIVITY)
    {
        RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
        if (post.riff && indexPath.row == 0)
        {
            RYRiffTrackTableViewCell *riffCell = [tableView dequeueReusableCellWithIdentifier:@"RiffCell" forIndexPath:indexPath];
            cell = riffCell;
        }
        else
        {
            // text post
            cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
        }
    }
    else if (_visualStatus == RECORD)
    {
        if (indexPath.row == 0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TextBlockCell" forIndexPath:indexPath];
        }
    }
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Almost universal themes
    [cell.imageView setImage:nil];
    [cell.textLabel setFont:[RYStyleSheet baseFont]];
    
    if (_visualStatus == ABOUT)
    {
        if (indexPath.section == 0)
        {
            //biography
            [cell.textLabel setText:_user.bio];
            [cell.textLabel setFont:[RYStyleSheet longFont]];
        }
    }
    else if (_visualStatus == ACTIVITY)
    {
        RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
        if (post.riff && indexPath.row == 0)
        {
            RYRiffTrackTableViewCell *riffCell = (RYRiffTrackTableViewCell*)cell;
            UIImage *maskedImage = [RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"play.png"];
            [riffCell.statusImageView setImage:maskedImage];
            
            [riffCell configureForRiff:post.riff];
        }
        else
        {
            NSAttributedString *attributedText = [RYServices createAttributedTextWithPost:post];
            
            [cell.textLabel setAttributedText:attributedText];
        }
    }
    else if (_visualStatus == RECORD)
    {
        if (indexPath.row == 0)
        {
            if (!_isRecording)
            {
                [cell.textLabel setText:@"Record a riff"];
                [cell.imageView setImage:[RYStyleSheet maskWithColor:[RYStyleSheet baseColor] forImageNamed:@"mic"]];
            }
            else
            {
                [cell.textLabel setText:@"Recording.."];
                [cell.imageView setImage:[RYStyleSheet maskWithColor:[UIColor redColor] forImageNamed:@"dot"]];
            }
        }
        else
        {
            RYTextBlockTableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:@"TextBlockCell" forIndexPath:indexPath];
            [textCell.textView setText:@"Details"];
        }
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0f;
    
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
    
    if (indexPath.row == 1 || post.riff == NULL)
    {
        CGSize constraint = CGSizeMake(self.view.frame.size.width, 20000);
        NSAttributedString *mainText = [RYServices createAttributedTextWithPost:post];
        CGRect result = [mainText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        height = MAX(result.size.height+20, height);
    }
    
    if (_visualStatus == ABOUT)
    {
        // Bio Section
        if (indexPath.section == 0)
        {
            CGSize constraint = CGSizeMake(self.view.frame.size.width, 20000);
            NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [RYStyleSheet longFont], NSFontAttributeName, nil];
            CGRect result = [_user.bio boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil];
            height = MAX(result.size.height+20, height);
        }
    }
    else if (_visualStatus == RECORD)
    {
        if (indexPath.row == 1)
            height = 88.0f;
    }
    
    return height;
}

#pragma mark -
#pragma mark - UITableView Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
    if (_visualStatus == ACTIVITY)
    {
        // Riff row
        if (post.riff && indexPath.row == 0)
        {
            // if not playing, begin
            if (!self.isPlaying)
            {
                self.isPlaying = YES;
                self.currentlyPlayingCell = (RYRiffTrackTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
                [self startRiffDownload:post.riff];
                return;
            }
            
            // stop any downloads
            else if (self.isDownloading)
            {
                [self clearRiffDownloading];
            }
            
            // already playing
            else if ([tableView indexPathForCell:self.currentlyPlayingCell].section == indexPath.section)
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
            else
            {
                //playing another, switch riff
                [self clearRiffDownloading];
                
                self.isPlaying = YES;
                self.currentlyPlayingCell = (RYRiffTrackTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
                [self startRiffDownload:post.riff];
            }
        }
        else
        {
            // open new view controller for chosen user
            
        }
    }
    else if (_visualStatus == RECORD)
    {
        if (indexPath.row == 0)
        {
            //riff
            [self recordButtonHit];
        }
        RYTextBlockTableViewCell *textBlockCell = (RYTextBlockTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [self setRiffContent:textBlockCell.textView.text];
    }
}

@end
