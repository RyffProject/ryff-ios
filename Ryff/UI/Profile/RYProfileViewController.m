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
#import "BlockAlertView.h"
#import "RYProfileInfoTableViewCell.h"
#import "RYProfilePostTableViewCell.h"

// Categories
#import "UIImage+Thumbnail.h"
#import "UIViewController+Extras.h"
#import "UIImage+Color.h"

// Frameworks
#import "UIImageView+SGImageCache.h"

// Associated View Controllers
#import "RYRiffCreateViewController.h"
#import "RYLoginViewController.h"

#define kProfileInfoCellReuseID @"ProfileInfoCell"
#define kProfilePostCellReuseID @"ProfilePostCell"

@interface RYProfileViewController () <POSTDelegate, UpdateUserDelegate, ProfileInfoCellDelegate, ProfilePostCellDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIView *imageWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *editImageLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, strong) RYUser *user;
@property (nonatomic, strong) NSArray *feedItems;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation RYProfileViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [_nameText setFont:[UIFont fontWithName:kRegularFont size:36.0f]];
    [_bioTextView setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    
    [_addButton setTintColor:[RYStyleSheet actionColor]];
    
    [_editImageLabel setFont:[UIFont fontWithName:kLightFont size:20.0f]];
    [_editImageLabel setTextColor:[UIColor whiteColor]];
    [_editImageLabel setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.4]];
    [_imageWrapperView setBackgroundColor:[RYStyleSheet foregroundColor]];
    [_imageWrapperView.layer setCornerRadius:_imageWrapperView.frame.size.width/8];
    [_imageWrapperView setClipsToBounds:YES];
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
    RYNewsfeedPost *post = _feedItems[indexPath.row];
    
    if (indexPath.section == 0)
    {
        // profile info -> calculate size with user bio
        height = kProfileInfoCellHeightMinusText + [post.user.bio boundingRectWithSize:CGSizeMake(kProfileInfoCellLabelRatio*tableView.frame.size.width, 20000) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:kProfileInfoCellFont} context:nil].size.height;
        height = MAX(height, kProfileInfoCellMinimumHeight);
        
    }
    else if (indexPath.section == 1)
    {
        // profile post -> calculate size with attributed text for post description
        height = kProfilePostCellHeightMinusText + [post.content boundingRectWithSize:CGSizeMake(kProfilePostCellLabelRatio*tableView.frame.size.width, 20000) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:kProfilePostCellFont} context:nil].size.height;
        height = MAX(height, kProfilePostCellMinimumHeight);
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
        [((RYProfilePostTableViewCell*)cell) configureForPost:post riffIndex:indexPath.row delegate:self];
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
    [_profileImageView setImage:avatarImage];
    
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
