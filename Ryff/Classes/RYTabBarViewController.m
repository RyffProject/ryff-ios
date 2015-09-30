//
//  RYTabBarViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYTabBarViewController.h"

// Data Managers
#import "RYServices.h"

// Data Objects
#import "RYUser.h"
#import "RYNewsfeedDataSource.h"
#import "RYUserFeedDataSource.h"

// Custom UI
#import "RYStyleSheet.h"
#import "UIImage+Color.h"
#import "UIImage+Size.h"
#import "UIViewController+Extras.h"

// Associated View Controller
#import "RYProfileViewController.h"
#import "RYNewsfeedContainerViewController.h"
#import "RYDiscoverViewController.h"
#import "RYNavigationController.h"

static const CGSize tabBarIconSize = {25, 25};

typedef NS_ENUM (NSInteger, RYTabIndex) {
    RYTabIndexNewsfeed = 0,
    RYTabIndexDiscover,
    RYTabIndexProfile,
    RYTabIndexAudioDeck
};

@interface RYTabBarViewController () <UITabBarControllerDelegate>

@property (nonatomic) RYNavigationController *newsfeedNavigationController;
@property (nonatomic) RYNavigationController *profileNavigationController;
@property (nonatomic) RYNavigationController *discoverNavigationController;
@property (nonatomic) RYNavigationController *audioDeckNavigationController;

@end

@implementation RYTabBarViewController

- (instancetype)init {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.delegate = self;
        
        _newsfeedNavigationController = [self newsfeed];
        _profileNavigationController = [self profile];
        _discoverNavigationController = [self discover];
        _audioDeckNavigationController = [self audioDeck];
        
        self.viewControllers = @[self.newsfeedNavigationController, self.discoverNavigationController, self.profileNavigationController, self.audioDeckNavigationController];
        self.selectedIndex = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tabBar setTintColor:[RYStyleSheet audioActionColor]];
    [self.tabBar setBackgroundImage:[[UIImage imageNamed:@"tabBar"] colorImage:[RYStyleSheet tabBarColor]]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kRegularFont size:12.0f]} forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark - TabBar Delegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([self.selectedViewController isKindOfClass:[RYNewsfeedContainerViewController class]] && [self.selectedViewController.tabBarItem isEqual:item])
    {
        UINavigationController *navController = ((RYNewsfeedContainerViewController *)self.selectedViewController).newsfeedNav;
        if (navController)
            [navController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - View Controllers

- (RYNavigationController *)newsfeed {
    RYNewsfeedDataSource *dataSource = [[RYNewsfeedDataSource alloc] init];
    RYPostsViewController *newsfeed = [[RYPostsViewController alloc] initWithDataSource: dataSource];
    newsfeed.title = @"Newsfeed";
    RYNavigationController *newsfeedNavigationController = [[RYNavigationController alloc] initWithRootViewController:newsfeed];
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:newsfeed.title image:[[UIImage imageNamed:@"stream"] imageWithSize:tabBarIconSize] tag:RYTabIndexNewsfeed];
    newsfeedNavigationController.tabBarItem = tabBarItem;
    [newsfeed addNewPostButtonToNavBar];
    return newsfeedNavigationController;
}

- (RYNavigationController *)discover {
    RYDiscoverViewController *discover = [[RYDiscoverViewController alloc] initWithNibName:nil bundle:nil];
    RYNavigationController *discoverNavigationController = [[RYNavigationController alloc] initWithRootViewController:discover];
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Discover" image:[[UIImage imageNamed:@"globe"] imageWithSize:tabBarIconSize] tag:RYTabIndexDiscover];
    discoverNavigationController.tabBarItem = tabBarItem;
    return discoverNavigationController;
}

- (RYNavigationController *)profile {
    RYPostsDataSource *dataSource = [RYUserFeedDataSource postsDataSourceWithUser:[RYRegistrationServices loggedInUser]];
    RYProfileViewController *profile = [[RYProfileViewController alloc] initWithDataSource:dataSource];
    RYNavigationController *profileNavigationController = [[RYNavigationController alloc] initWithRootViewController:profile];
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:profile.title image:[[UIImage imageNamed:@"user"] imageWithSize:tabBarIconSize] tag:RYTabIndexProfile];
    profileNavigationController.tabBarItem = tabBarItem;
    return profileNavigationController;
}

- (RYNavigationController *)audioDeck {
    RYAudioDeckViewController *audioDeck = [[RYAudioDeckViewController alloc] initWithAudioDeck:[RYAudioDeck sharedAudioDeck]];
    RYNavigationController *audioDeckNagivationController = [[RYNavigationController alloc] initWithRootViewController:audioDeck];
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Audio Deck" image:[[UIImage imageNamed:@"audioPlaying"] imageWithSize:tabBarIconSize] tag:RYTabIndexAudioDeck];
    audioDeckNagivationController.tabBarItem = tabBarItem;
    return audioDeckNagivationController;
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}

@end
