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
#import "RYRiffReviewViewController.h"
#import "RYRiffCreateViewController.h"

@interface RYProfileViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate, POSTDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UIButton *recentActivityButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong) NSString *riffContent;

@end

@implementation RYProfileViewController

- (void) viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
    
    [[RYServices sharedInstance] getMyPostsForDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _user = [RYServices loggedInUser];
    
    [self configureForUser:_user];
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
}

- (IBAction)addHit:(id)sender
{
    RYRiffCreateViewController *riffCreateVC = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"RiffCreateVC"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:riffCreateVC];
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)aboutHit:(id)sender
{
    [self clearRiff];
    [_tableView reloadData];
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
