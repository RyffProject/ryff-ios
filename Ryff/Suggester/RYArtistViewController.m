//
//  RYArtistViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYArtistViewController.h"

// Custom UI
#import "RYStyleSheet.h"

@interface RYArtistViewController ()

@end

@implementation RYArtistViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[RYStyleSheet baseColor]];
}


@end
