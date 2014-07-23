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

// Categories
#import "UIImage+Thumbnail.h"
#import "UIViewController+Extras.h"
#import "UIImage+Color.h"

// Frameworks
#import "UIImageView+SGImageCache.h"

// Associated View Controllers
#import "RYRiffCreateViewController.h"
#import "RYLoginViewController.h"

@interface RYProfileViewController () <POSTDelegate, UpdateUserDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIView *imageWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *editImageLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UIButton *recentActivityButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
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
    
    [_nameText setFont:[UIFont fontWithName:kRegularFont size:36.0f]];
    
    [_recentActivityButton setTintColor:[RYStyleSheet actionColor]];
    [_addButton setTintColor:[RYStyleSheet actionColor]];
    [_aboutButton setTintColor:[RYStyleSheet actionColor]];
    
    [_editImageLabel setFont:[UIFont fontWithName:kLightFont size:20.0f]];
    [_editImageLabel setTextColor:[UIColor whiteColor]];
    [_editImageLabel setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.4]];
    [_imageWrapperView setBackgroundColor:[RYStyleSheet foregroundColor]];
    [_imageWrapperView.layer setCornerRadius:_imageWrapperView.frame.size.width/8];
    [_imageWrapperView setClipsToBounds:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editImageTapped:)];
    [_imageWrapperView addGestureRecognizer:tapGesture];
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
    
    // Display name
    [_nameText setText:_user.firstName];
    
    // prep activity
    [self setFeedItems:_user.activity];
    
    if (_user)
    {
        // Profile picture
        if (_user.avatarURL)
            [_profileImageView setImageForURL:_user.avatarURL placeholder:[UIImage imageNamed:@"user"]];
        else
            [_profileImageView setImage:[UIImage imageNamed:@"user"]];
        
        if (_isLoggedInProfile)
        {
            [_editImageLabel setHidden:NO];
            [_settingsButton setHidden:NO];
        }
        else
        {
            // not logged in user, remove settings button
            [_editImageLabel setHidden:YES];
            [_settingsButton setHidden:YES];
        }
        
        [[RYServices sharedInstance] getUserPostsForUser:_user.userId Delegate:self];
    }
    else
    {
        // guest
        _isLoggedInProfile = NO;
        [_editImageLabel setHidden:YES];
        [_profileImageView setImage:[UIImage imageNamed:@"user"]];
        self.feedItems = nil;
    }
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)settingsHit:(id)sender
{
    if (!_user)
    {
        [self presentLogIn];
    }
    else
    {
        UIActionSheet *settingsSheet = [[UIActionSheet alloc] initWithTitle:@"Settings" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Sign Out", @"Change Avatar", @"Edit Profile",  nil];
        if (isIpad)
            [settingsSheet showFromRect:_settingsButton.frame inView:self.view animated:YES];
        else
            [settingsSheet showInView:self.view];
    }
}

- (IBAction)activityHit:(id)sender
{

}

- (IBAction)addHit:(id)sender
{
    RYRiffCreateViewController *riffCreateVC = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"RiffCreateVC"];
    [self presentViewController:riffCreateVC animated:YES completion:nil];
}

- (IBAction)aboutHit:(id)sender
{
    
}

#pragma mark - Edit Profile

// Present log in if user requests action that requires an account
- (void) presentLogIn
{
    UIViewController *navCon  = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"LoginVC"];
    [self presentViewController:navCon animated:YES completion:nil];
}

- (void) editImageTapped:(UITapGestureRecognizer*)sender
{
    if (_isLoggedInProfile)
        [self presentProfilePictureOptions];
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
    [_profileImageView setImage:avatarImage];
    
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

@end
