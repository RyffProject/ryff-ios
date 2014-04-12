//
//  RYRegisterViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRegister2ViewController.h"

// Custom UI
#import "UIViewController+Extras.h"

// Services
#import "RYServices.h"

@interface RYRegister2ViewController () <POSTDelegate>

@end

@implementation RYRegister2ViewController

- (IBAction)submitRegistration:(id)sender
{
    NSString *username  = _usernameText.text;
    NSString *password  = _passwordText.text;
    NSString *email     = _emailText.text;
    NSString *bio       = @"";
    NSString *name      = @"Chris";
    
    if (username.length > 0 && password.length > 0 && email.length > 0)
    {
        //submit request
        NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
        
        requestDict[@"email"]       = email;
        requestDict[@"username"]    = username;
        requestDict[@"password"]    = password;
        requestDict[@"bio"]         = bio;
        requestDict[@"name"]        = name;
        requestDict[@"longitude"]   = @0;
        requestDict[@"latitude"]    = @0;
        [[RYServices sharedInstance] submitPOST:kRegistrationAction withDict:requestDict forDelegate:self];
    }
}



#pragma mark -
#pragma mark - POSTDelegate

- (void) connectionFailed
{
    
}
- (void) postFailed
{
    
}
- (void) postSucceeded:(id)response
{
    NSLog(@"Success: %@",response);
    [self showCheckHUDWithTitle:@"Successfully Registered!" forDuration:1.0];
    [self performSelector:@selector(dismissViewController) withObject:self afterDelay:1.5];
}

#pragma mark -
#pragma mark - Transitions

- (void)dismissViewController
{
    //if you are presnting ViewController modally. then use below code
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
