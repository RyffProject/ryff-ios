//
//  RYRegisterViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRegisterViewController.h"

// Custom UI
#import "BlockAlertView.h"

// Associated View Controllers
#import "RYRegister2ViewController.h"

@interface RYRegisterViewController () <UITextFieldDelegate>

@end

@implementation RYRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"ContinueRegistration"])
    {
        // check that places are filled in!
        NSString *username  = _usernameText.text;
        NSString *password  = _passwordText.text;
        NSString *email     = _emailText.text;
        if (username.length > 0 && password.length > 0 && email.length > 0)
            return YES;
        else
        {
            // must have more data
            BlockAlertView* lengthAlert   = [[BlockAlertView alloc] initWithTitle:@"Incomplete" message:@"Required fields have been left blank, please try again." delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
            [lengthAlert show];
            
            return NO;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ContinueRegistration"])
    {
        NSString *username  = _usernameText.text;
        NSString *password  = _passwordText.text;
        NSString *email     = _emailText.text;
        
        RYRegister2ViewController *reg2VC = segue.destinationViewController;
        [reg2VC setUsername:username];
        [reg2VC setPassword:password];
        [reg2VC setEmail:email];
    }
}

#pragma mark -
#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
