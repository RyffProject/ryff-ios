//
//  RYRootRegistrationViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/17/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRootRegistrationViewController.h"

// Custom UI
#import "RYStyleSheet.h"

@interface RYRootRegistrationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registrationButton;

@end

@implementation RYRootRegistrationViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Style
    [_loginButton.titleLabel setFont:[RYStyleSheet titleFont]];
    [_registrationButton.titleLabel setFont:[RYStyleSheet titleFont]];
    [_loginButton setTintColor:[UIColor whiteColor]];
    [_registrationButton setTintColor:[UIColor whiteColor]];
    
    [self.view setBackgroundColor:[RYStyleSheet baseColor]];
}

@end
