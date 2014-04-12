//
//  RYCoreTabBarViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYCoreTabBarViewController.h"
#import "RYStyleSheet.h"

@interface RYCoreTabBarViewController ()

@end

@implementation RYCoreTabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBar setTintColor:[RYStyleSheet baseColor]];
}
@end
