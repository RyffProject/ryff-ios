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
#import "RYTag.h"

// Custom UI
#import "RYStyleSheet.h"
#import "BlockAlertView.h"
#import "RYProfileInfoTableViewCell.h"

// Categories
#import "UIImage+Thumbnail.h"
#import "UIViewController+Extras.h"
#import "UIImage+Color.h"

// Frameworks
#import <AVFoundation/AVFoundation.h>

// Associated View Controllers
#import "RYRiffCreateViewController.h"
#import "RYLoginViewController.h"
#import "RYNewsfeedTableViewController.h"
#import "RYUserListViewController.h"

#define kProfileInfoCellReuseID @"ProfileInfoCell"

@interface RYProfileViewController () <PostDelegate, UpdateUserDelegate, ProfileInfoCellDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *settingsBarButton;
@property (nonatomic, strong) UIBarButtonItem *notificationsBarButton;

// Data
@property (nonatomic, strong) RYUser *user;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation RYProfileViewController

- (void) viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
    
    self.riffSection = 1;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureForUser:_user];
}

- (void) configureForUser:(RYUser *)user
{
    _user = user ? user : [RYServices loggedInUser];
    
    // prep activity
    self.feedItems = nil;
    
    if (_user)
    {
        [[RYServices sharedInstance] getUserPostsForUser:_user.userId page:nil delegate:self];
        [self setTitle:_user.username];
        
        if (_user.userId == [RYServices loggedInUser].userId)
            [self addNewPostButtonToNavBar];
    }
    
    [self.tableView reloadData];
}

- (void) addSettingsOptions
{
    if (self.navigationItem)
    {
        CGSize barButtonSize = CGSizeMake(30, 30);
        _settingsBarButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"cloud"] createThumbnailToFillSize:barButtonSize] style:UIBarButtonItemStylePlain target:self action:@selector(settingsTapped:)];
        _notificationsBarButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"rss"] createThumbnailToFillSize:barButtonSize] style:UIBarButtonItemStylePlain target:self action:@selector(notificationsTapped:)];
        [self.navigationItem setLeftBarButtonItems:@[_settingsBarButton,_notificationsBarButton]];
    }
}

#pragma mark -
#pragma mark - Actions

- (void) settingsTapped:(id)sender
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
            [settingsSheet showFromBarButtonItem:_settingsBarButton animated:YES];
        }
        else
            [settingsSheet showInView:self.view];
    }
}

- (void) notificationsTapped:(id)sender
{
    NSLog(@"show notifications");
}

#pragma mark - ProfileInfoCell Delegate

- (void) addNewRiff
{
    RYRiffCreateViewController *riffCreateVC = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"RiffCreateVC"];
    [self presentViewController:riffCreateVC animated:YES completion:nil];
}

- (void) editImageAction
{
    if (_user.userId == [RYServices loggedInUser].userId)
        [self presentProfilePictureOptions];
}

- (void) followersAction
{
    if (_user.numFollowers > 0)
    {
        NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
        RYUserListViewController *userList = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"userListVC"];
        [userList configureWithFollowersForUser:_user];
        [self.navigationController pushViewController:userList animated:YES];
    }
}

- (void) tagSelected:(NSInteger)tagSelected
{
    if (tagSelected < _user.tags.count)
    {
        RYTag *tag = _user.tags[tagSelected];
        
        NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
        RYNewsfeedTableViewController *feedVC = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"newsfeedVC"];
        [feedVC configureWithTags:@[tag.tag]];
        if (self.navigationController)
            [self.navigationController pushViewController:feedVC animated:YES];
        else
            [self presentViewController:feedVC animated:YES completion:nil];
    }
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

- (void) postFailed:(NSString*)reason
{
    
}
- (void) postSucceeded:(NSArray *)posts
{
    [self setFeedItems:posts];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Overrides

- (void) avatarAction:(NSInteger)riffIndex
{
    RYNewsfeedPost *post = self.feedItems[riffIndex];
    if (post.user.userId != [RYServices loggedInUser].userId)
        [super avatarAction:riffIndex];
}

#pragma mark - TableView data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + [super numberOfSectionsInTableView:tableView];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if (section == 0)
        numRows = 1;
    else if (section == 1)
        numRows = [super tableView:tableView numberOfRowsInSection:self.riffSection];
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kProfileInfoCellReuseID forIndexPath:indexPath];
    }
    else if (indexPath.section == 1)
        cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:self.riffSection]];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (indexPath.section == 0)
    {
        // profile info -> calculate size with user bio
        CGFloat widthMinusText = kProfileInfoCellWidthMinusText;
        
        UITextView *sizingView = [[UITextView alloc] init];
        [sizingView setFont:kProfileInfoCellFont];
        [sizingView setText:_user.bio];
        CGSize resultSize = [sizingView sizeThatFits:CGSizeMake(tableView.frame.size.width-widthMinusText, 20000)];
        height = resultSize.height + kProfileInfoCellHeightMinusText;
        height = MAX(height, kProfileInfoCellMinimumHeight);
        
    }
    else if (indexPath.section == 1)
    {
        height = [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:self.riffSection]];
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
        [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:self.riffSection]];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1)
        [super tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:self.riffSection]];
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
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

#pragma mark -
#pragma mark - UserUpdateDelegate

- (void) updateSucceeded:(RYUser*)user
{
    [self configureForUser:user];
    [self showCheckHUDWithTitle:@"Updated Profile" forDuration:1.0f];
}

- (void) updateFailed:(NSString *)reason
{
    UIAlertView *updateFailedAlert = [[UIAlertView alloc] initWithTitle:@"Update Failed" message:[NSString stringWithFormat:@"Could not update user properties: %@",reason] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [updateFailedAlert show];
}

@end
