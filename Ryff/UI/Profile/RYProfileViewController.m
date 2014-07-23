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
#import "RYProfileInfoTableViewCell.h"
#import "BlockAlertView.h"

// Categories
#import "UIImage+Thumbnail.h"
#import "UIViewController+Extras.h"
#import "UIImage+Color.h"

// Frameworks
#import "UIImageView+SGImageCache.h"

// Associated View Controllers
#import "RYRiffCreateViewController.h"
#import "RYLoginViewController.h"

#define kProfileCellReuseID @"profileCell"

@interface RYProfileViewController () <POSTDelegate, UpdateUserDelegate, ProfileInfoCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, assign) BOOL isLoggedInProfile;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation RYProfileViewController

- (void) viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureForUser:_user];
}

- (void) configureForUser:(RYUser *)user
{
    _user = user ? user : [RYServices loggedInUser];
    
    // configure for editing if looking at the logged in user's profile
    _isLoggedInProfile = (_user && (_user.userId == [RYServices loggedInUser].userId));
    
    // prep activity
    [self setFeedItems:_user.activity];
    
    if (_user)
        [[RYServices sharedInstance] getUserPostsForUser:_user.userId Delegate:self];
    else
        self.feedItems = nil;
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Actions

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
            CGRect convertedFrame = [_tableView convertRect:presentingFrame toView:self.view];
            [settingsSheet showFromRect:convertedFrame inView:self.view animated:YES];
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
    if (_isLoggedInProfile)
        [self presentProfilePictureOptions];
}

#pragma mark - Edit Profile

// Present log in if user requests action that requires an account
- (void) presentLogIn
{
    UIViewController *navCon  = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"LoginVC"];
    [self presentViewController:navCon animated:YES completion:nil];
}

#pragma mark - Settings

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
    [_tableView reloadData];
    
    [[RYServices sharedInstance] getMyPostsForDelegate:self];
}

- (void) updateFailed:(NSString *)reason
{
    UIAlertView *updateFailedAlert = [[UIAlertView alloc] initWithTitle:@"Update Failed" message:[NSString stringWithFormat:@"Could not update user properties: %@",reason] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [updateFailedAlert show];
}

#pragma mark -
#pragma mark - RYRiffStreamingCoreViewController Override

#pragma mark - TableView datasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + [super numberOfSectionsInTableView:tableView];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows;
    if (section == 0)
        numRows = 1;
    else
        numRows = [super tableView:tableView numberOfRowsInSection:(section-1)];
    return numRows;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0)
        cell = [_tableView dequeueReusableCellWithIdentifier:kProfileCellReuseID];
    else
        cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section-1)]];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if (indexPath.section == 0)
        height = 260.0f;
    else
        height = [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section-1)]];
    return height;
}

#pragma mark - TableView delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [((RYProfileInfoTableViewCell*)cell) configureForUser:_user delegate:self parentTableView:tableView];
    }
    else
    {
        [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section-1)]];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        
    }
    else
    {
        [super tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section-1)]];
    }
}

@end
