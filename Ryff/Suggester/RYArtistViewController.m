//
//  RYArtistViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYArtistViewController.h"

// Data Managers
#import "RYServices.h"

// Data objects
#import "RYUser.h"
#import "RYNewsfeedPost.h"

// Custom UI
#import "RYStyleSheet.h"
#import "BlockAlertView.h"
#import "UIImage+Color.h"

// Frameworks
#import "UIImageView+SGImageCache.h"

@interface RYArtistViewController () <FriendsDelegate, POSTDelegate>

@end

@implementation RYArtistViewController

- (void)viewDidLoad
{
    self.riffTableView = _tableView;
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // setup navbar buttons
    UIBarButtonItem *friends = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(friendsHit:)];
    [friends setImage:[UIImage imageNamed:@"friend"]];
    [friends setTintColor:[RYStyleSheet actionColor]];
    [self.navigationItem setLeftBarButtonItem:friends];
    
    // setup navbar buttons
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(nextHit:)];
    [next setImage:[UIImage imageNamed:@"next"]];
    [next setTintColor:[RYStyleSheet actionColor]];
    [self.navigationItem setRightBarButtonItem:next];
    
    [self configureForArtist];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[RYServices sharedInstance] getUserPostsForUser:_artist.userId Delegate:self];
}

#pragma mark -
#pragma mark - Setup UI

- (void) setupFriendBarButtonItem:(UIImage*)image;
{
    UIButton* newButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [newButton addTarget:self action:@selector(friendsHit:)
       forControlEvents:UIControlEventTouchUpInside];
    [newButton setImage:image forState:UIControlStateNormal];
    newButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIBarButtonItem *butt4 = [[UIBarButtonItem alloc]initWithCustomView:newButton];
    
    [self.navigationItem setLeftBarButtonItem:butt4];
}

#pragma mark -
#pragma mark - Prep

- (void) configureForArtist
{
    if (_artist.avatarURL)
        [_profileImage setImageForURL:_artist.avatarURL placeholder:[UIImage imageNamed:@"user"]];
    else
        [_profileImage setImage:[UIImage imageNamed:@"user"]];
    [_nameText setText:_artist.nickname];
    [_bioText setText:_artist.bio];
}

#pragma mark -
#pragma mark - Bar Button Methods

- (void) friendsHit:(UIBarButtonItem*)sender
{
    NSInteger numImages = 3;
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    // load all rotations of these images
    for (NSInteger i = 0; i < 4; i++)
    {
        for (NSInteger imNum = 1; imNum <= numImages; imNum++)
        {
            UIImage *loadingImage = [[UIImage imageNamed:[NSString stringWithFormat:@"Cylindric_%ld",(long)imNum]] imageWithOverlayColor:[RYStyleSheet actionColor]];
            loadingImage = [RYStyleSheet image:loadingImage RotatedByRadians:M_PI_2*i];
            [images addObject:loadingImage];
        }
    }
    
    UIImage *workingCycle = [UIImage animatedImageWithImages:images duration:1.5];
    [self setupFriendBarButtonItem:workingCycle];
    
    [self toggleFriendStatus];
}

#pragma mark -
#pragma mark - Friend Delegate

- (void) friendConfirmed
{
    [self setupFriendBarButtonItem:[[UIImage imageNamed:@"checkmark"] imageWithOverlayColor:[RYStyleSheet actionColor]]];
    _friends = YES;
}
- (void) friendDeleted
{
    [self setupFriendBarButtonItem:[[UIImage imageNamed:@"friend"] imageWithOverlayColor:[RYStyleSheet actionColor]]];
    _friends = NO;
}
- (void) actionFailed
{
    if (_friends)
        [self setupFriendBarButtonItem:[[UIImage imageNamed:@"checkmark"] imageWithOverlayColor:[RYStyleSheet actionColor]]];
    else
        [self setupFriendBarButtonItem:[[UIImage imageNamed:@"friend"] imageWithOverlayColor:[RYStyleSheet actionColor]]];
}

- (void) toggleFriendStatus
{
    if (!_friends)
        [[RYServices sharedInstance] addFriend:_artist.userId forDelegate:self];
    else
        [[RYServices sharedInstance] deleteFriend:_artist.userId forDelegate:self];
}

- (void) nextHit:(UIBarButtonItem*)sender
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"next" object:nil]];
}

#pragma mark -
#pragma mark - POSTDelegate (for user posts)

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
    [_tableView reloadData];
}

@end
