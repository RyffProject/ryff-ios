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
#import "RYRegistrationServices.h"

// Data Objects
#import "RYTag.h"
#import "RYNotification.h"

// Custom UI
#import "RYStyleSheet.h"
#import "RYProfileInfoTableViewCell.h"
#import "PXAlertView.h"
#import "RYRefreshControl.h"

// Categories
#import "UIImage+Thumbnail.h"
#import "UIViewController+Extras.h"
#import "UIImage+Color.h"
#import "UIColor+Hex.h"
#import "UIImagePickerController+Orientations.h"

// Frameworks
#import <AVFoundation/AVFoundation.h>

// Associated View Controllers
#import "RYRiffCreateViewController.h"
#import "RYLoginViewController.h"
#import "RYTagFeedViewController.h"
#import "RYUserListViewController.h"
#import "RYNotificationsTableViewController.h"
#import "RYRiffDetailsViewController.h"

#define kProfileInfoCellReuseID @"ProfileInfoCell"
#define kLoggedOutCellReuseID @"loggedOutCell"

@interface RYProfileViewController () <PostDelegate, UpdateUserDelegate, UsersDelegate, ProfileInfoCellDelegate, FollowDelegate, NotificationSelectionDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *notificationsBarButton;
@property (nonatomic, strong) UIPopoverController *notificationsPopover;
@property (nonatomic, strong) RYRefreshControl *refreshControl;

// Data
@property (nonatomic, strong) RYUser *user;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, assign) BOOL profileTab;

@end

@implementation RYProfileViewController

#pragma mark -
#pragma mark - ViewController Lifecycle

- (void) viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
    
    _refreshControl = [[RYRefreshControl alloc] initInScrollView:_tableView];
    _refreshControl.tintColor = [RYStyleSheet postActionColor];
    [_refreshControl addTarget:self action:@selector(refreshContent:) forControlEvents:UIControlEventValueChanged];
    
    self.riffSection = 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"e9e9e9"]];
    [self configureForUser:_user];
    if (_user)
    {
        [[RYServices sharedInstance] getUserWithId:@(_user.userId) orUsername:nil delegate:self];
        [[RYServices sharedInstance] getUserPostsForUser:_user.userId page:nil delegate:self];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (_notificationsPopover && [_notificationsPopover isPopoverVisible])
    {
        [_notificationsPopover presentPopoverFromBarButtonItem:_notificationsBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark -
#pragma mark - Configuration

- (void) refreshContent:(RYRefreshControl *)refreshControl
{
    if (_user)
    {
        [[RYServices sharedInstance] getUserWithId:@(_user.userId) orUsername:nil delegate:self];
        [[RYServices sharedInstance] getUserPostsForUser:_user.userId page:nil delegate:self];
    }
}

- (void) configureForUser:(RYUser *)user
{
    _user = user ? user : [RYRegistrationServices loggedInUser];
    
    if (_user)
        [self setTitle:_user.username];
    else
        [self setTitle:@"Me"];
    
    [self.tableView reloadData];
}

- (void) configureForUsername:(NSString *)username
{
    [[RYServices sharedInstance] getUserWithId:nil orUsername:username delegate:self];
}

- (void) addSettingsOptions
{
    if (self.navigationItem)
    {
        _notificationsBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notification"] style:UIBarButtonItemStylePlain target:self action:@selector(notificationsTapped:)];
        [self.navigationItem setLeftBarButtonItems:@[_notificationsBarButton]];
        
        [self addNewPostButtonToNavBar];
        _profileTab = YES;
    }
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
            CGRect convertedRect = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] toView:self.view];
            CGRect realFrame = CGRectMake(convertedRect.origin.x + presentingFrame.origin.x, convertedRect.origin.y + presentingFrame.origin.y, presentingFrame.size.width, presentingFrame.size.height);
            [settingsSheet showFromRect:realFrame inView:self.view animated:YES];
        }
        else
            [settingsSheet showInView:self.view];
    }
}

- (void) messageAction
{
    
}

- (void) followAction
{
    if (_user.userId != [RYRegistrationServices loggedInUser].userId)
    {
        [[RYServices sharedInstance] follow:!_user.isFollowing user:_user.userId forDelegate:self];
    }
}

- (void) notificationsTapped:(id)sender
{
    if (_user)
    {
        RYNotificationsTableViewController *notificationsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"notificationsVC"];
        [notificationsVC configureWithDelegate:self];
        if (isIpad)
        {
            _notificationsPopover = [[UIPopoverController alloc] initWithContentViewController:notificationsVC];
            _notificationsPopover.backgroundColor = [RYStyleSheet lightBackgroundColor];
            [_notificationsPopover presentPopoverFromBarButtonItem:_notificationsBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            [self.navigationController pushViewController:notificationsVC animated:YES];
        }
    }
    else
        [self presentLogIn];
}

#pragma mark - ProfileInfoCell Delegate

- (void) editImageAction
{
    if (_user.userId == [RYRegistrationServices loggedInUser].userId)
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
        RYTagFeedViewController *feedVC = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"tagFeedVC"];
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
        [[RYRegistrationServices sharedInstance] logOut];
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
    [navCon setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navCon animated:YES completion:nil];
}

#pragma mark -
#pragma mark - Notifications Delegate

- (void) notificationSelected:(RYNotification *)notification
{
    [_notificationsPopover dismissPopoverAnimated:NO];
    
    UIViewController *vcToPush;
    
    switch (notification.type) {
        case FOLLOW_NOTIF:
        {
            if (notification.users.count > 0)
            {
                RYUser *user = notification.users.lastObject;
                RYProfileViewController *profileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"profileVC"];
                [profileVC configureForUser:user];
                vcToPush = profileVC;
            }
            break;
        }
        case UPVOTE_NOTIF:
        case REMIX_NOTIF:
        {
            if (notification.post)
            {
                RYPost *post = notification.post;
                RYRiffDetailsViewController *riffDetails = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"riffDetails"];
                [riffDetails configureForPost:post];
                vcToPush = riffDetails;
            }
            break;
        }
        case MENTION_NOTIF:
        {
            if (notification.posts.count > 0)
            {
                RYPost *post = notification.posts.lastObject;
                RYRiffDetailsViewController *riffDetails = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"riffDetails"];
                [riffDetails configureForPost:post];
                vcToPush = riffDetails;
            }
            break;
        }
        case UNRECOGNIZED_NOTIF:
            break;
    }
    
    if (vcToPush)
        [self.navigationController pushViewController:vcToPush animated:YES];
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
#pragma mark - Users Delegate

// fetched user with username (from call sent by configureWithUsername:)
- (void) retrievedUsers:(NSArray *)users
{
    [_refreshControl endRefreshing];
    RYUser *user = [users firstObject];
    [self configureForUser:user];
}

#pragma mark -
#pragma mark - Follow Delegate

- (void) follow:(BOOL)following confirmedForUser:(RYUser *)user
{
    _user = user;
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void) followFailed:(NSString *)reason
{
    NSLog(@"follow user failed: %@",reason);
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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
    [PXAlertView showAlertWithTitle:@"Update Failed" message:[NSString stringWithFormat:@"Could not update user properties: %@",reason]];
}

#pragma mark -
#pragma mark - Overrides

- (void) avatarAction:(NSInteger)riffIndex
{
    RYPost *post = self.feedItems[riffIndex];
    if (post.user.userId != [RYRegistrationServices loggedInUser].userId)
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
        if (_user)
            cell = [tableView dequeueReusableCellWithIdentifier:kProfileInfoCellReuseID forIndexPath:indexPath];
        else
            cell = [tableView dequeueReusableCellWithIdentifier:kLoggedOutCellReuseID forIndexPath:indexPath];
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
        if (_user)
        {
            // profile info -> calculate size with user bio
            if (_user.bio.length > 0 || _profileTab)
            {
                CGFloat widthMinusText = kProfileInfoCellWidthMinusText;
                
                UITextView *sizingView = [[UITextView alloc] init];
                [sizingView setFont:kProfileInfoCellFont];
                [sizingView setText:_user.bio];
                CGSize resultSize = [sizingView sizeThatFits:CGSizeMake(tableView.frame.size.width-widthMinusText, 20000)];
                height = resultSize.height + kProfileInfoCellHeightMinusText;
                height = MAX(height, kProfileInfoCellMinimumHeight);
            }
            else
                height = kProfileInfoCellMinimumHeight;
        }
        else
            height = 200.0f;
    }
    else if (indexPath.section == 1)
    {
        height = [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:self.riffSection]];
    }
    return height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return 0.01f; }
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return 0.01f; }

#pragma mark - TableView delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // profile info
        if (_user)
        {
            [((RYProfileInfoTableViewCell*)cell) configureForUser:_user delegate:self parentTableView:self.tableView];
            
            if (_profileTab)
                [((RYProfileInfoTableViewCell*)cell) enableUserSettingOptions];
        }
        else
            [cell setBackgroundColor:nil];
    }
    else if (indexPath.section == 1)
    {
        [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:self.riffSection]];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (!_user)
            [self presentLogIn];
    }
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
    
    [PXAlertView showAlertWithTitle:@"Profile Picture" message:@"Select a new profile picture." cancelTitle:@"Cancel" otherTitles:@[@"Take a Photo", @"From Library"] completion:^(BOOL cancelled, NSInteger buttonIndex, NSString *inputValue) {
        if (!cancelled)
        {
            if (buttonIndex == 0)
            {
                // take photo
                [self takePhoto];
            }
            else if (buttonIndex == 1)
            {
                // choose from library
                [self pickPhoto];
            }
        }
    }];
}

-(UIImagePickerController *) imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.navigationBar.tintColor = [UIColor whiteColor];
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
    UIImage *avatarImage = [info[UIImagePickerControllerOriginalImage] thumbnailOfSize:CGSizeMake(avatarSize, avatarSize)];
    
    [[RYRegistrationServices sharedInstance] updateAvatar:avatarImage forDelegate:self];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

#pragma mark -
#pragma mark - Keyboard Notifications

/*
 Keyboard will appear, should center alertView higher up
 */
-(void)onKeyboardAppear:(NSNotification *)notification
{
    // position of keyboard before animation
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = CGRectMake(0, 0, MAX(keyboardRect.size.width,keyboardRect.size.height), MIN(keyboardRect.size.width,keyboardRect.size.height));
    
    CGPoint viewCenter;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
        viewCenter = CGPointMake(0.5*MIN(self.view.bounds.size.width,self.view.bounds.size.height), 0.5*MAX(self.view.bounds.size.width,self.view.bounds.size.height)-keyboardRect.size.height/2);
    else
        viewCenter = CGPointMake(0.5*MAX(self.view.bounds.size.width,self.view.bounds.size.height), 0.5*MIN(self.view.bounds.size.width,self.view.bounds.size.height)-keyboardRect.size.height/2);
    
    // keyboard to show at bottom of screen, adjust accordingly
    CGFloat animationDuration   = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger curve             = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    [UIView animateWithDuration:animationDuration delay:0.f options:curve animations:^{
        
        UITableViewCell *topCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if ([topCell isKindOfClass:[RYProfileInfoTableViewCell class]])
        {
            RYProfileInfoTableViewCell *profileCell = (RYProfileInfoTableViewCell *)topCell;
            if (profileCell.bioTextView.isFirstResponder)
            {
                CGRect cellFrame = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] toView:self.view];
                cellFrame.origin.y -= _tableView.contentOffset.y;
                CGPoint bioTextOrigin = CGPointMake(cellFrame.origin.x+profileCell.bioTextView.frame.origin.x, cellFrame.origin.y+profileCell.bioTextView.frame.origin.y);
                CGPoint offsetChange = CGPointMake(0, (profileCell.bioTextView.frame.size.height/2+bioTextOrigin.y)-viewCenter.y);
                _tableView.contentOffset = CGPointMake(_tableView.contentOffset.x+offsetChange.x, _tableView.contentOffset.y+offsetChange.y);
            }
        }
        
    } completion:nil];
}

/*
 Keyboard will appear, should center alertView at vc center
 */
-(void)onKeyboardHide:(NSNotification *)notification
{
    // keyboard to show at bottom of screen, adjust accordingly
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = CGRectMake(0, 0, MAX(keyboardRect.size.width,keyboardRect.size.height), MIN(keyboardRect.size.width,keyboardRect.size.height));
    CGFloat animationDuration   = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger curve             = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    [UIView animateWithDuration:animationDuration delay:0.f options:curve animations:^{
        
        UITableViewCell *topCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if ([topCell isKindOfClass:[RYProfileInfoTableViewCell class]])
        {
            RYProfileInfoTableViewCell *profileCell = (RYProfileInfoTableViewCell *)topCell;
            if (profileCell.bioTextView.isFirstResponder)
            {
                CGPoint offsetChange = CGPointMake(0, -keyboardRect.size.height/2);
                CGPoint offset = CGPointMake(_tableView.contentOffset.x+offsetChange.x, _tableView.contentOffset.y+offsetChange.y);
                _tableView.contentOffset = CGPointMake(MAX(offset.x, 0), MAX(offset.y,0));
            }
        }
    } completion:nil];
}

@end
