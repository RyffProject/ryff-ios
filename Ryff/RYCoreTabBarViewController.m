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

// Associated View Controller
#import "RYProfileViewController.h"

@interface RYCoreTabBarViewController ()

@end

@implementation RYCoreTabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBar setTintColor:[RYStyleSheet baseColor]];
    
    for (UIViewController *vc in self.viewControllers)
    {
        if ([vc isKindOfClass:[RYProfileViewController class]])
        {
            RYProfileViewController *profController = (RYProfileViewController*)vc;
            // Should be user's object
            RYUser *loggedInUser = [RYServices loggedInUser];
            [profController setUser:loggedInUser];
        }
    }
}
@end
