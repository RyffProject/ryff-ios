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
#import "UIViewController+Extras.h"
#import "UIImage+Color.h"

// Associated View Controllers
#import "RYRiffCreateViewController.h"

@interface RYProfileViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, UITextFieldDelegate, POSTDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *imageWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *editImageLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UIButton *recentActivityButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, assign) BOOL loggedInProfile;

@end

@implementation RYProfileViewController

- (void) viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
    
    _user = [RYServices loggedInUser];
    
    [self configureForUser:_user];
    [_tableView reloadData];
    
    [_nameText setFont:[UIFont fontWithName:kRegularFont size:36.0f]];
    
    if (_loggedInProfile)
    {
        [_editImageLabel setFont:[UIFont fontWithName:kLightFont size:20.0f]];
        [_editImageLabel setTextColor:[UIColor whiteColor]];
        [_editImageLabel setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.4]];
        [_imageWrapperView setBackgroundColor:[RYStyleSheet foregroundColor]];
        [_imageWrapperView.layer setCornerRadius:100.0f];
        [_imageWrapperView setClipsToBounds:YES];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editImageTapped:)];
        [_imageWrapperView addGestureRecognizer:tapGesture];
    }
    else
    {
        [_editImageLabel setHidden:YES];
    }
    
    [_recentActivityButton setTintColor:[RYStyleSheet actionColor]];
    [_addButton setTintColor:[RYStyleSheet actionColor]];
    [_aboutButton setTintColor:[RYStyleSheet actionColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[RYServices sharedInstance] getMyPostsForDelegate:self];
}

- (void) configureForUser:(RYUser *)user
{
    // configure for editing if looking at the logged in user's profile
    if (user.userId == [RYServices loggedInUser].userId)
        _loggedInProfile = YES;
    
    // Profile picture
    [_profileImageView setImage:user.profileImage];
    
    // Edit button
    if (![user.username isEqualToString:[RYServices loggedInUser].username])
    {
        // remove edit button
        [_editButton removeFromSuperview];
    }
    
    // Display name
    [_nameText setText:user.firstName];
    
    // prep activity
    [self setFeedItems:user.activity];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)editHit:(id)sender
{
    
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

- (void) editImageTapped:(UITapGestureRecognizer*)sender
{
    
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

@end
