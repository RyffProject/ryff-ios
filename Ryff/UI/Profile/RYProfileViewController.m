//
//  RYProfileViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYProfileViewController.h"

// Data Managers
#import "RYServices.h"

// Data Objects
#import "RYUser.h"

// Custom UI
#import "RYStyleSheet.h"

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
    // Profile picture
    [_profileImageView setImage:user.profileImage];
    
    // Edit button
    if ([user.username isEqualToString:[RYServices loggedInUser].username])
    {
        
    }
    else
    {
        [_editButton removeFromSuperview];
    }
    
    // Display name
    [_nameText setText:user.firstName];
}

@end
