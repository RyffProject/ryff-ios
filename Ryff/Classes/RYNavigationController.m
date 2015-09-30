//
//  RYNavigationController.m
//  Ryff
//
//  Created by Chris Laganiere on 9/5/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

#import "RYNavigationController.h"

@interface RYNavigationController ()

@end

@implementation RYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationBar setBarTintColor:[RYStyleSheet postActionColor]];
    [self.navigationBar setTranslucent:NO];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    
    NSDictionary *navbarTitleAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                            NSFontAttributeName: [UIFont fontWithName:kRegularFont size:24.0f]};
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleAttributes];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:3.0f forBarMetrics:UIBarMetricsDefault];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
