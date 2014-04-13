//
//  RYRegisterViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYCoreViewController.h"

@interface RYRegister2ViewController : RYCoreViewController

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *email;

@property (weak, nonatomic) IBOutlet UIView *avatarOwnerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;

- (IBAction)submitRegistration:(id)sender;

@end
