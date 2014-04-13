//
//  RYArtistViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYArtistViewController.h"

// Data objects
#import "RYUser.h"

// Custom UI
#import "RYStyleSheet.h"
#import "BlockAlertView.h"

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
    
    // setup navbar buttons
    UIBarButtonItem *friends = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(friendsHit:)];
    [friends setImage:[UIImage imageNamed:@"friend"]];
    [friends setTintColor:[RYStyleSheet baseColor]];
    [self.navigationItem setLeftBarButtonItem:friends];
    
    // setup navbar buttons
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(nextHit:)];
    [next setImage:[UIImage imageNamed:@"next"]];
    [next setTintColor:[RYStyleSheet baseColor]];
    [self.navigationItem setRightBarButtonItem:next];
    
    [self configureForArtist];
}

#pragma mark -
#pragma mark - Prep

- (void) configureForArtist
{
    [_profileImage setImage:_artist.profileImage];
    [_nameText setText:_artist.firstName];
    [_bioText setText:_artist.bio];
}

#pragma mark -
#pragma mark - Bar Button Methods

- (void) friendsHit:(UIBarButtonItem*)sender
{
    
}

- (void) nextHit:(UIBarButtonItem*)sender
{
    
}

@end
