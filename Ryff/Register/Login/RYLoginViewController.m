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
#import "RYLoginTableViewCell.h"
#import "PXAlertView.h"

// Categories
#import "UIViewController+Extras.h"

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

@interface RYLoginViewController () <UpdateUserDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *tapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *wrapperView;
@property (weak, nonatomic) IBOutlet UIButton *userTypeButton;

// Data
@property (nonatomic, assign) BOOL newUser;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end

@implementation RYLoginViewController

#pragma mark -
#pragma mark - ViewController Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _newUser = NO;
    
    [self.view setBackgroundColor:[RYStyleSheet audioBackgroundColor]];
    
    [_userTypeButton.titleLabel setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    [_userTypeButton setTintColor:[UIColor whiteColor]];
    [_userTypeButton setTitle:@"New User" forState:UIControlStateNormal];
    
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

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    _username                     = ((UITextField*)[usernameCell viewWithTag:6]).text;
    
    UITableViewCell *passwordCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kPasswordRow inSection:0]];
    _password                     = ((UITextField*)[passwordCell viewWithTag:6]).text;
    
    if (_username.length && _password.length)
    {
        if (_newUser)
        {
            // register
            NSDictionary *parameters = @{@"username" : _username, @"password" : _password};
            [[RYServices sharedInstance] registerUserWithPOSTDict:parameters forDelegate:self];
            [self showHUDWithTitle:@"Registering"];
        }
        else
        {
            // log in
            [[RYServices sharedInstance] logInUserWithUsername:_username Password:_password forDelegate:self];
            [self showHUDWithTitle:@"Logging in"];
        }
    }
    else
    {
        [PXAlertView showAlertWithTitle:@"Log In Failed" message:@"Check credentials"];
    }
}

/*
 User wants to switch between Log In and Register
 */
- (IBAction)userTypeButtonHit:(id)sender
{
    _newUser = !_newUser;
    
    NSString *buttonTitle = _newUser ? @"Returning User" : @"New User";
    [_userTypeButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kLoginRow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark -
#pragma mark - UpdateUserDelegate

- (void) updateFailed:(NSString*)reason
{
    [self hideHUD];
    [PXAlertView showAlertWithTitle:@"Log In Error" message:[NSString stringWithFormat:@"Something went wrong: %@", reason]];
}

- (void) updateSucceeded:(RYUser*)user
{
    [self hideHUD];
    [self showCheckHUDWithTitle:@"Welcome" forDuration:0.5];
    
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
            [cell.contentView setBackgroundColor:[RYStyleSheet tabBarColor]];
            [cell.contentView roundTop];
            
            UITextField *usernameField = (UITextField*)[cell viewWithTag:6];
            [usernameField setFont:[UIFont fontWithName:kRegularFont size:24.0f]];
            usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: [UIColor lightTextColor],
                                                                                                                      NSFontAttributeName: [UIFont fontWithName:kRegularFont size:24.0f]}];
            [usernameField setSecureTextEntry:NO];
            [usernameField setTintColor:[UIColor whiteColor]];
            
            [[cell viewWithTag:8] setBackgroundColor:[RYStyleSheet audioBackgroundColor]];
            
            break;
        }
        case kPasswordRow:
        {
            // password input
            [cell.contentView setBackgroundColor:[RYStyleSheet tabBarColor]];
            
            UITextField *passwordField = (UITextField*)[cell viewWithTag:6];
            passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor lightTextColor],
                                                                                                                      NSFontAttributeName: [UIFont fontWithName:kRegularFont size:24.0f]}];
            [passwordField setSecureTextEntry:YES];
            [passwordField setTintColor:[UIColor whiteColor]];
            
            [[cell viewWithTag:8] setBackgroundColor:[RYStyleSheet audioBackgroundColor]];
            break;
        }
        case kLoginRow:
        {
            NSString *cellTitle = _newUser ? @"Register" : @"Log In";
            [((RYLoginTableViewCell*)cell) configureWithTitle:cellTitle];
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
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGPoint viewCenter;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
        viewCenter = CGPointMake(0.5*MIN(self.view.bounds.size.width,self.view.bounds.size.height), 0.5*MAX(self.view.bounds.size.width,self.view.bounds.size.height)-keyboardRect.size.height/2);
    else
        viewCenter = CGPointMake(0.5*MAX(self.view.bounds.size.width,self.view.bounds.size.height), 0.5*MIN(self.view.bounds.size.width,self.view.bounds.size.height)-keyboardRect.size.width/2);
    
    // keyboard to show at bottom of screen, adjust accordingly
    CGFloat animationDuration   = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger curve             = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    [UIView animateWithDuration:animationDuration delay:0.f options:curve animations:^{
        if (isIpad)
            [_wrapperView setCenter:viewCenter];
        else
            [_wrapperView setCenter:CGPointMake(viewCenter.x, viewCenter.y + 50)];
    } completion:nil];
}

/*
 Keyboard will appear, should center tableView at vc center
 */
-(void)onKeyboardHide:(NSNotification *)notification
{
    CGPoint viewCenter;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
        viewCenter = CGPointMake(0.5*MIN(self.view.bounds.size.width,self.view.bounds.size.height), 0.5*MAX(self.view.bounds.size.width,self.view.bounds.size.height));
    else
        viewCenter = CGPointMake(0.5*MAX(self.view.bounds.size.width,self.view.bounds.size.height), 0.5*MIN(self.view.bounds.size.width,self.view.bounds.size.height));
    
    // keyboard to show at bottom of screen, adjust accordingly
    CGFloat animationDuration   = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger curve             = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    [UIView animateWithDuration:animationDuration delay:0.f options:curve animations:^{
        [_wrapperView setCenter:viewCenter];
    } completion:nil];
}

@end
