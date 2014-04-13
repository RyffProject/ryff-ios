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

enum VisualStatus : NSUInteger {
    ABOUT = 1,
    ACTIVITY = 2,
    RECORD = 3
};

@interface RYProfileViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, assign) enum VisualStatus visualStatus;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, assign) BOOL isRecording;

@end

@implementation RYProfileViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self configureForUser:_user];
    [self setVisualStatus:ABOUT];
    [_tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self clearRiffDownloading];
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
        sectionCount = _user.activity.count;
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
        RYNewsfeedPost *post = [_user.activity objectAtIndex:section];
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
    
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
    }
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Almost universal themes
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
            [cell.textLabel setText:@"Details"];
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
        
    }
}

@end
