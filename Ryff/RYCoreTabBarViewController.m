//
//  RYCoreTabBarViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYCoreTabBarViewController.h"

// Data Managers
#import "RYServices.h"

// Data Objects
#import "RYUser.h"

// Custom UI
#import "RYStyleSheet.h"
#import "UIImage+Color.h"

// Associated View Controller
#import "RYProfileViewController.h"

@interface RYCoreTabBarViewController ()

@end

@implementation RYCoreTabBarViewController

- (void)viewDidLoad
{
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

@end
