//
//  RYNewsfeedNavigationController.m
//  Ryff
//
//  Created by Christopher Laganiere on 8/16/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNewsfeedNavigationController.h"

@interface RYNewsfeedNavigationController ()

@end

@implementation RYNewsfeedNavigationController

- (void) viewDidLoad
{
    for (UIViewController *viewController in self.viewControllers)
    {
        [viewController setExtendedLayoutIncludesOpaqueBars:YES];
        [viewController setAutomaticallyAdjustsScrollViewInsets:NO];
    }
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    
    [viewController setEdgesForExtendedLayout:UIRectEdgeBottom];
    [viewController setAutomaticallyAdjustsScrollViewInsets:NO];
    [viewController setExtendedLayoutIncludesOpaqueBars:YES];
}

@end
