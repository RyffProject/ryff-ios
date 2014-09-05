//
//  RYCoreViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYCoreViewController.h"

// Custom UI
#import "RYStyleSheet.h"

@interface RYCoreViewController ()

@end

@implementation RYCoreViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[RYStyleSheet lightBackgroundColor]];
    
    [self.navigationController.navigationBar setBarTintColor:[RYStyleSheet postActionColor]];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    NSDictionary *navbarTitleAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                            NSFontAttributeName: [UIFont fontWithName:kRegularFont size:24.0f]};
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleAttributes];
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:3.0f forBarMetrics:UIBarMetricsDefault];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
