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
#import "RYRiff.h"
#import "RYNewsfeedPost.h"

// Custom UI
#import "RYStyleSheet.h"
#import "BlockAlertView.h"
#import "RYProfileInfoTableViewCell.h"
#import "RYProfilePostTableViewCell.h"

// Categories
#import "UIImage+Thumbnail.h"
#import "UIViewController+Extras.h"
#import "UIImage+Color.h"

// Frameworks
#import "UIImageView+SGImageCache.h"
#import <AVFoundation/AVFoundation.h>

// Associated View Controllers
#import "RYRiffCreateViewController.h"
#import "RYLoginViewController.h"

#define kProfileInfoCellReuseID @"ProfileInfoCell"
#define kProfilePostCellReuseID @"ProfilePostCell"

@interface RYProfileViewController () <POSTDelegate, UpdateUserDelegate, ProfileInfoCellDelegate, ProfilePostCellDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, AVAudioPlayerDelegate>

// Data
@property (nonatomic, strong) RYUser *user;
@property (nonatomic, strong) NSArray *feedItems;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) RYProfilePostTableViewCell *currentlyPlayingCell;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, strong) NSMutableData *riffData;
@property (nonatomic, assign) CGFloat totalBytes;
@property (nonatomic, strong) NSURLConnection *riffConnection;
@property (nonatomic, strong) NSTimer *updateTimer;

@end

@implementation RYProfileViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureForUser:_user];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self clearRiff];
}

- (void) configureForUser:(RYUser *)user
{
    _user = user ? user : [RYServices loggedInUser];
    
    // prep activity
    [self setFeedItems:_user.activity];
    
    if (_user)
        [[RYServices sharedInstance] getUserPostsForUser:_user.userId Delegate:self];
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Actions

#pragma mark - ProfileInfoCell Delegate

- (void) settingsAction:(CGRect)presentingFrame
{
    if (!_user)
    {
        // guest
        [self presentLogIn];
    }
    else
    {
        // user
        UIActionSheet *settingsSheet = [[UIActionSheet alloc] initWithTitle:@"Settings" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Sign Out", @"Change Avatar", @"Edit Profile",  nil];
        if (isIpad)
        {
            CGRect convertedRect = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] toView:self.view];
            CGRect realFrame = CGRectMake(convertedRect.origin.x + presentingFrame.origin.x, convertedRect.origin.y + presentingFrame.origin.y, presentingFrame.size.width, presentingFrame.size.height);
            [settingsSheet showFromRect:realFrame inView:self.view animated:YES];
        }
        else
            [settingsSheet showInView:self.view];
    }

}

- (void) addNewRiff
{
    RYRiffCreateViewController *riffCreateVC = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"RiffCreateVC"];
    [self presentViewController:riffCreateVC animated:YES completion:nil];
}

- (void) editImageAction
{
    [self presentProfilePictureOptions];
}

#pragma mark - ProfilePost Delegate

/*
 Download/play/pause riff track for post corresponding to riffIndex
 */
- (void) playerControlAction:(NSInteger)riffIndex
{
    RYNewsfeedPost *post = _feedItems[riffIndex];
    // if not playing, begin
    if (!_audioPlayer && !self.isDownloading)
    {
        self.currentlyPlayingCell = (RYProfilePostTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:riffIndex inSection:1]];
        [self startRiffDownload:post.riff];
        return;
    }
    
    // stop any downloads
    if (self.isDownloading)
        [self clearRiff];
    
    // already playing
    if (_audioPlayer && _audioPlayer.isPlaying && [self.tableView indexPathForCell:self.currentlyPlayingCell].section == riffIndex)
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
    else if (_audioPlayer && _audioPlayer.isPlaying)
    {
        //playing another, switch riff
        [self clearRiff];
        
        self.currentlyPlayingCell = (RYProfilePostTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:riffIndex inSection:1]];
        [self startRiffDownload:post.riff];
    }
}

/*
 Upvote post corresponding to riffIndex
 */
- (void) upvoteAction:(NSInteger)riffIndex
{
    
}

/*
 Repost post corresponding to riffIndex
 */
- (void) repostAction:(NSInteger)riffIndex
{
    
}

/*
 Follow user for post corresponding to riffIndex
 */
- (void) followAction:(NSInteger)riffIndex
{
    
}

#pragma mark - Edit Profile

/*
 Settings actionsheet -> sign out, update avatar, edit profile
 */
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // sign out
        [[RYServices sharedInstance] logOut];
        [self configureForUser:nil];
    }
    else if (buttonIndex == 1)
    {
        // update avatar
        [self presentProfilePictureOptions];
    }
    else
    {
        // edit profile
    }
}

// Present log in if user requests action that requires an account
- (void) presentLogIn
{
    UIViewController *navCon  = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"LoginVC"];
    [self presentViewController:navCon animated:YES completion:nil];
}

#pragma mark -
#pragma mark - POSTDelegate

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
#pragma mark - Riff Downloading / Playing

- (void) startRiffDownload:(RYRiff*)riff
{
    _isDownloading = YES;
    [_currentlyPlayingCell startDownloading];
    
    NSURL *riffURL = riff.URL;
    NSURLRequest *dataRequest = [NSURLRequest requestWithURL:riffURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:45];
    _riffData = [[NSMutableData alloc] initWithLength:0];
    _riffConnection = [[NSURLConnection alloc] initWithRequest:dataRequest delegate:self startImmediately:YES];
}

- (void) startRiffPlaying:(NSData*)riffData
{
    if (!_audioPlayer.isPlaying)
    {
        NSError *error;
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:riffData error:&error];
        [_audioPlayer setDelegate:self];
        _audioPlayer.numberOfLoops = 0;
        _audioPlayer.volume = 1.0f;
        [_audioPlayer prepareToPlay];
        
        if (_audioPlayer == nil)
            NSLog(@"Error: %@", [error localizedDescription]);
        else
        {
            [_audioPlayer play];
        }
        
        _updateTimer= [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLeft) userInfo:nil repeats:YES];
    }
}

- (void) clearRiff
{
    [_updateTimer invalidate];
    _updateTimer = nil;
    [_currentlyPlayingCell clearAudio];
    _currentlyPlayingCell = nil;
    [_audioPlayer stop];
    _audioPlayer = nil;
    _totalBytes = 0;
    _riffData = nil;
    _riffConnection = nil;
    _audioPlayer = nil;
    _isDownloading = NO;
}

#pragma mark -
#pragma mark - Timer UI Update

- (void)updateTimeLeft
{
    CGFloat timeProgress = _audioPlayer.currentTime / _audioPlayer.duration;
    
    // update your UI with timeLeft
    [self.currentlyPlayingCell updateTimeRemaining:timeProgress];
}

#pragma mark -
#pragma mark - Riff Download Delegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_riffData setLength:0];
    [self setTotalBytes:response.expectedContentLength];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_riffData appendData:data];
    [_currentlyPlayingCell updateDownloadIndicatorWithBytes:_riffData.length outOf:_totalBytes];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"%@",[error localizedDescription]);
    [_currentlyPlayingCell finishDownloading:NO];
    [self clearRiff];
    _isDownloading = NO;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_currentlyPlayingCell finishDownloading:YES];
    [self startRiffPlaying:_riffData];
    _isDownloading = NO;
}

#pragma mark -
#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self clearRiff];
}

#pragma mark -
#pragma mark - TableView data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if (section == 0)
        numRows = 1;
    else if (section == 1)
        numRows = _feedItems.count;
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0)
        cell = [tableView dequeueReusableCellWithIdentifier:kProfileInfoCellReuseID forIndexPath:indexPath];
    else if (indexPath.section == 1)
        cell = [tableView dequeueReusableCellWithIdentifier:kProfilePostCellReuseID];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (indexPath.section == 0)
    {
        // profile info -> calculate size with user bio
        CGFloat widthRatio = kProfileInfoCellLabelRatio;
        height = kProfileInfoCellHeightMinusText + [_user.bio boundingRectWithSize:CGSizeMake(widthRatio*tableView.frame.size.width, 20000) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kProfileInfoCellFont} context:nil].size.height;
        height = MAX(height, kProfileInfoCellMinimumHeight);
        
    }
    else if (indexPath.section == 1)
    {
        // profile post -> calculate size with attributed text for post description
        RYNewsfeedPost *post = _feedItems[indexPath.row];
        CGFloat widthRatio = kProfilePostCellLabelRatio;
        height = [[RYStyleSheet createProfileAttributedTextWithPost:post] boundingRectWithSize:CGSizeMake(widthRatio*self.tableView.frame.size.width, 20000) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        height = MAX(height+kProfilePostCellHeightMinusText, kProfilePostCellMinimumHeight);
    }
    return height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

#pragma mark - TableView delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // profile info
        [((RYProfileInfoTableViewCell*)cell) configureForUser:_user delegate:self parentTableView:self.tableView];
    }
    else if (indexPath.section == 1)
    {
        // profile post
        RYNewsfeedPost *post = _feedItems[indexPath.row];
        [((RYProfilePostTableViewCell*)cell) configureForPost:post attributedText:[RYStyleSheet createProfileAttributedTextWithPost:post] riffIndex:indexPath.row delegate:self];
    }
}

#pragma mark -
#pragma mark - User Avatar Photo Picking

- (void)presentProfilePictureOptions
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"No camera detected!");
        [self pickPhoto];
        return;
    }
    
    BlockAlertView *photoChoice = [[BlockAlertView alloc] initWithTitle:@"Profile Picture" message:@"Select a new profile picture." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take a Photo", @"From Library", nil];
    [photoChoice setDidDismissBlock:^(BlockAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            // take photo
            [self takePhoto];
        }
        else if (buttonIndex == 2)
        {
            // choose from library
            [self pickPhoto];
        }
    }];
    [photoChoice show];
}

-(UIImagePickerController *) imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

-(void) takePhoto
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void) pickPhoto
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    CGFloat avatarSize = 400.f;
    UIImage *avatarImage = [info[UIImagePickerControllerOriginalImage] createThumbnailToFillSize:CGSizeMake(avatarSize, avatarSize)];
    
    [[RYServices sharedInstance] updateAvatar:avatarImage forDelegate:self];
}

#pragma mark -
#pragma mark - UserUpdateDelegate

- (void) updateSucceeded:(RYUser *)newUser
{
    [self configureForUser:newUser];
}

- (void) updateFailed:(NSString *)reason
{
    UIAlertView *updateFailedAlert = [[UIAlertView alloc] initWithTitle:@"Update Failed" message:[NSString stringWithFormat:@"Could not update user properties: %@",reason] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [updateFailedAlert show];
}

@end
