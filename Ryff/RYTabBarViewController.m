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
#import "RYPostsDataSource.h"
#import "RYNewsfeedDataSource.h"

// Custom UI
#import "RYStyleSheet.h"
#import "UIImage+Color.h"

// Associated View Controller
#import "RYProfileViewController.h"
#import "RYNewsfeedContainerViewController.h"

typedef NS_ENUM (NSInteger, RYTabIndex) {
    RYTabIndexNewsfeed = 0
};

@interface RYTabBarViewController () <UITabBarControllerDelegate>

@property (nonatomic) UINavigationController *newsfeedNavigationController;

@end

@implementation RYTabBarViewController

- (instancetype)init {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.delegate = self;
        _newsfeedNavigationController = [self newsfeedNavigationController];
        
        self.viewControllers = @[self.newsfeedNavigationController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tabBar setTintColor:[RYStyleSheet audioActionColor]];
    [self.tabBar setTranslucent:NO];
    [self.tabBar setBackgroundImage:[[UIImage imageNamed:@"tabBar"] colorImage:[RYStyleSheet tabBarColor]]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kRegularFont size:12.0f]} forState:UIControlStateNormal];
    
    for (UIViewController *viewController in self.viewControllers)
    {
        if ([viewController isKindOfClass:[UINavigationController class]])
        {
            UIViewController *potentialProfile = ((UINavigationController*)viewController).viewControllers.firstObject;
            if ([potentialProfile isKindOfClass:[RYProfileViewController class]])
                [((RYProfileViewController *)potentialProfile) addSettingsOptions];
        }
    }
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

- (UINavigationController *)newsfeedNavigationController {
    RYNewsfeedDataSource *dataSource = [[RYNewsfeedDataSource alloc] init];
    RYPostsViewController *newsfeed = [[RYPostsViewController alloc] initWithDataSource: dataSource];
    UINavigationController *newsfeedNavigationController = [[UINavigationController alloc] initWithRootViewController:newsfeed];
    return newsfeedNavigationController;
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}

@end
