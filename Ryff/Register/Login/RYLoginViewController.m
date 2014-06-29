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
#import "UIViewController+Extras.h"
#import "RYLoginTableViewCell.h"

// Categories
#import "UIView+Styling.h"

// Data Managers
#import "RYServices.h"
#import "SSKeychain.h"

#define kFieldCellReuseID @"FieldCell"
#define kLoginCellReuseID @"LoginCell"

#define kUsernameRow 0
#define kPasswordRow 1
#define kLoginRow 2

@interface RYLoginViewController () <POSTDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *tapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RYLoginViewController

#pragma mark -
#pragma mark - ViewController Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[RYStyleSheet backgroundColor]];
    
    UITapGestureRecognizer *backgroundTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [_tapView addGestureRecognizer:backgroundTapGesture];
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - UI

- (void)loginHit
{
    [self.view endEditing:YES];
    
    UITableViewCell *usernameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kUsernameRow inSection:0]];
    NSString *username            = ((UITextField*)[usernameCell viewWithTag:6]).text;
    
    UITableViewCell *passwordCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kPasswordRow inSection:0]];
    NSString *password            = ((UITextField*)[passwordCell viewWithTag:6]).text;
    
    if (username.length && password.length)
    {
        //submit
        [[RYServices sharedInstance] logInUserWithUsername:username Password:password forDelegate:self];
        [self showHUDWithTitle:@"Logging in"];
    }
    else
    {
        UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"Log In Failed" message:@"Check credentials" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [emptyAlert show];
    }
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
#pragma mark - GestureRecognizer Delegate

- (void) backgroundTap:(UITapGestureRecognizer*)sender
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark - UITableView Data Source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0f;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.row) {
        case kUsernameRow:
        case kPasswordRow:
            cell = [tableView dequeueReusableCellWithIdentifier:kFieldCellReuseID];
            break;
        case kLoginRow:
            cell = [tableView dequeueReusableCellWithIdentifier:kLoginCellReuseID];
            break;
        default:
            break;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

#pragma mark -
#pragma mark - UITableView Delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case kUsernameRow:
        {
            // username input
            [cell.contentView setBackgroundColor:[RYStyleSheet foregroundColor]];
            [cell.contentView roundTop];
            
            UITextField *usernameField = (UITextField*)[cell viewWithTag:6];
            [usernameField setFont:[UIFont fontWithName:kRegularFont size:24.0f]];
            usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                                      NSFontAttributeName: [UIFont fontWithName:kRegularFont size:24.0f]}];
            [usernameField setSecureTextEntry:NO];
            
            [[cell viewWithTag:8] setBackgroundColor:[RYStyleSheet backgroundColor]];
            
            break;
        }
        case kPasswordRow:
        {
            // password input
            [cell.contentView setBackgroundColor:[RYStyleSheet foregroundColor]];
            
            UITextField *passwordField = (UITextField*)[cell viewWithTag:6];
            passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                                      NSFontAttributeName: [UIFont fontWithName:kRegularFont size:24.0f]}];
            [passwordField setSecureTextEntry:YES];
            
            [[cell viewWithTag:8] setBackgroundColor:[RYStyleSheet backgroundColor]];
            break;
        }
        case kLoginRow:
        {
            [((RYLoginTableViewCell*)cell) configure];
        }
            
        default:
            break;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kLoginRow)
        [self loginHit];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark - Keyboard Delegate

/*
 Keyboard will appear, should center tableView higher up
 */
-(void)onKeyboardAppear:(NSNotification *)notification
{
    // position of keyboard before animation
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    if (keyboardRect.origin.y + keyboardRect.size.height > self.view.center.y)
    {
        // keyboard to show at bottom of screen, adjust accordingly
        CGFloat animationDuration   = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        NSInteger curve             = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
        [UIView animateWithDuration:animationDuration delay:0.f options:curve animations:^{
            [_tableView setCenter:CGPointMake(self.view.center.x, self.view.center.y - (keyboardRect.size.height/2))];
        } completion:nil];
    }
}

/*
 Keyboard will appear, should center tableView at vc center
 */
-(void)onKeyboardHide:(NSNotification *)notification
{
    // keyboard to show at bottom of screen, adjust accordingly
    CGFloat animationDuration   = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger curve             = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    [UIView animateWithDuration:animationDuration delay:0.f options:curve animations:^{
        [_tableView setCenter:self.view.center];
    } completion:nil];
}

@end
