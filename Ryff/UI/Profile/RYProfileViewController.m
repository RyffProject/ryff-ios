//
//  RYProfileViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYProfileViewController.h"

// Data Objects
#import "RYUser.h"
#import "RYNewsfeedPost.h"

// Custom UI
#import "RYStyleSheet.h"
#import "RYRiffTrackTableViewCell.h"
#import "BlockAlertView.h"
#import "UIViewController+Extras.h"
#import "UIImage+Color.h"

// Associated View Controllers
#import "RYRiffEditViewController.h"

enum VisualStatus : NSUInteger {
    ABOUT = 1,
    ACTIVITY = 2,
    RECORD = 3
};

@interface RYProfileViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate, POSTDelegate>

@property (nonatomic, assign) enum VisualStatus visualStatus;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong) NSString *riffContent;

@end

@implementation RYProfileViewController

- (void) viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
    [self prepForRecording];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _user = [RYServices loggedInUser];
    
    [self configureForUser:_user];
    [self setVisualStatus:ABOUT];
    [_tableView reloadData];
    
    [_recentActivityButton setImage:[[UIImage imageNamed:@"newsfeed"] imageWithOverlayColor:[RYStyleSheet baseColor]] forState:UIControlStateNormal];
    [_addButton setImage:[[UIImage imageNamed:@"plus"] imageWithOverlayColor:[RYStyleSheet baseColor]] forState:UIControlStateNormal];
    [_aboutButton setImage:[[UIImage imageNamed:@"user"] imageWithOverlayColor:[RYStyleSheet baseColor]] forState:UIControlStateNormal];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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

#pragma mark -
#pragma mark - Button Actions

- (IBAction)editHit:(id)sender
{
    
}

- (IBAction)activityHit:(id)sender
{
    [self setVisualStatus:ACTIVITY];
    [self clearRiff];
    [_tableView reloadData];
    
    [[RYServices sharedInstance] getMyPostsForDelegate:self];
}

- (IBAction)addHit:(id)sender
{
    [self setVisualStatus:RECORD];
    [self clearRiff];
    [_tableView reloadData];
}

- (IBAction)aboutHit:(id)sender
{
    [self setVisualStatus:ABOUT];
    [self clearRiff];
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
                [self presentRiffEdit];
            }
        }];
        [recordConfirmation show];
    }
    
    [self.tableView reloadData];
}

- (void) presentRiffEdit
{
    UINavigationController *navCon = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"riffEditNC"];
    RYRiffEditViewController *riffEdit = [navCon.viewControllers firstObject];
    RYRiff *newRiff = [RYRiff riffWithURL:[RYServices pathForRiff]];
    [riffEdit configureWithRiff:newRiff];
    [self presentViewController:navCon animated:YES completion:nil];
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
        sectionCount = [super numberOfSectionsInTableView:tableView];
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
        rowCount = [super tableView:tableView numberOfRowsInSection:section];
    }
    else if (_visualStatus == RECORD)
    {
        rowCount = 1;
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
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
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    else if (_visualStatus == RECORD)
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
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
    [cell.textLabel setFont:[RYStyleSheet regularFont]];
    
    if (_visualStatus == ABOUT)
    {
        if (indexPath.section == 0)
        {
            //biography
            [cell.textLabel setText:_user.bio];
            [cell.textLabel setFont:[RYStyleSheet lightFont]];
        }
        else if (indexPath.section == 1)
        {
            // Groups
            [cell.textLabel setText:@"Drummer, Los Angeles"];
        }
    }
    else if (_visualStatus == ACTIVITY)
    {
        [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
    else if (_visualStatus == RECORD)
    {
        if (indexPath.row == 0)
        {
            if (!_isRecording)
            {
                [cell.textLabel setText:@"Record a riff"];
                [cell.imageView setImage:[[UIImage imageNamed:@"mic"] imageWithOverlayColor:[RYStyleSheet baseColor]]];
            }
            else
            {
                [cell.textLabel setText:@"Recording.."];
                [cell.imageView setImage:[[UIImage imageNamed:@"dot"] imageWithOverlayColor:[UIColor redColor]]];
            }
        }
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0f;
    
    if (_visualStatus == ACTIVITY)
    {
        height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    else if (_visualStatus == ABOUT)
    {
        // Bio Section
        if (indexPath.section == 0)
        {
            CGSize constraint = CGSizeMake(self.view.frame.size.width, 20000);
            NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [RYStyleSheet lightFont], NSFontAttributeName, nil];
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
    
    if (_visualStatus == ACTIVITY)
    {
        // Riff row
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    else if (_visualStatus == RECORD)
    {
        if (indexPath.row == 0)
        {
            //riff
            [self recordButtonHit];
        }
    }
}

@end
