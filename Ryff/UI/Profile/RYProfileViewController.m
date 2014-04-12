//
//  RYProfileViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYProfileViewController.h"
#import "RYUser.h"

@interface RYProfileViewController ()

@end

@implementation RYProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self configureForUser:_user];
}

- (void) configureForUser:(RYUser *)user
{
    [_nameText setText:user.firstName];
}

@end
