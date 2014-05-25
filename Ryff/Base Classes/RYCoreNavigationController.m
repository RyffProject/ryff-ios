//
//  RYCoreNavigationController.m
//  Ryff
//
//  Created by Christopher Laganiere on 5/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYCoreNavigationController.h"

#import "RYStyleSheet.h"

@interface RYCoreNavigationController ()

@end

@implementation RYCoreNavigationController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationBar setBackgroundColor:[RYStyleSheet backgroundColor]];
    [self.navigationBar setTranslucent:NO];
}

@end
