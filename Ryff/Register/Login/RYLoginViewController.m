//
//  RYLoginViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/17/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYLoginViewController.h"

// Custom UI
#import "RYStyleSheet.h"
#import "UIImage+Color.h"
#import "UIViewController+Extras.h"

// Data Managers
#import "RYServices.h"
#import "SSKeychain.h"

@interface RYLoginViewController () <POSTDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation RYLoginViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [_usernameText setDelegate:self];
    [_passwordText setDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // style images
    [_loginButton.imageView setImage:[[UIImage imageNamed:@"next"] imageWithOverlayColor:[UIColor whiteColor]]];
    
    //give avatar tap gesture recognizer
    UITapGestureRecognizer *backgroundTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.view addGestureRecognizer:backgroundTap];
    
    [self.view setBackgroundColor:[RYStyleSheet baseColor]];
}

#pragma mark -
#pragma mark - UI

- (IBAction)loginHit:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *username = _usernameText.text;
    NSString *password = _passwordText.text;
    
    if (username.length && password.length)
    {
        //submit
        [[RYServices sharedInstance] logInUserWithUsername:username Password:password forDelegate:self];
    }
    else
    {
        UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"Log In Failed" message:@"Check credentials" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [emptyAlert show];
    }
    [self showHUDWithTitle:@"Logging in"];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TextFields

- (void)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark - POSTDelegate

- (void) connectionFailed
{
    
}
- (void) postFailed:(NSString*)reason
{
    [self hideHUD];
    UIAlertView *postWarning = [[UIAlertView alloc] initWithTitle:@"Post Error" message:[NSString stringWithFormat:@"Error: %@", reason] delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
    [postWarning show];
}
- (void) postSucceeded:(id)response
{
    
    NSDictionary *responseDict = response;
    NSDictionary *userDict = [responseDict objectForKey:kUserObjectKey];
    if (userDict)
    {
        [[NSUserDefaults standardUserDefaults] setObject:userDict forKey:kLoggedInUserKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self hideHUD];
    [self showCheckHUDWithTitle:@"Welcome back" forDuration:0.5];
    
    [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:0.5];
}

#pragma mark -
#pragma mark - Transitions

- (void)dismissViewController
{
    //if you are presnting ViewController modally. then use below code
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
