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
#import "UIImage+Thumbnail.h"
#import "BlockAlertView.h"

// Services
#import "RYServices.h"
#import "RYLocationServices.h"

@interface RYRegister2ViewController () <POSTDelegate, LocationDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *latitude;

@end

@implementation RYRegister2ViewController

#pragma mark UI

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[RYLocationServices sharedInstance] requestLocationCoordinatesForDelegate:self];
    
    // style image
    [_avatarImageView.layer setCornerRadius:50.0f];
    [_avatarImageView setClipsToBounds:YES];
    
    
    
    //give avatar tap gesture recognizer
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)];
    [_avatarImageView setUserInteractionEnabled:YES];
    [_avatarImageView addGestureRecognizer:singleFingerTap];
    
    UITapGestureRecognizer *backgroundTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.view addGestureRecognizer:backgroundTap];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[RYLocationServices sharedInstance] setLocationDelegate:nil];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)submitRegistration:(id)sender
{
    NSString *username  = _username;
    NSString *password  = _password;
    NSString *email     = _email;
    NSString *bio       = _bioTextView.text;
    NSString *name      = _nicknameTextField.text;
    
    if (username.length > 0 && password.length > 0 && email.length > 0)
    {
        if (_latitude && _longitude)
        {
            //coordinates found
            //submit request
            NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
            
            requestDict[@"email"]       = email;
            requestDict[@"username"]    = username;
            requestDict[@"password"]    = password;
            requestDict[@"bio"]         = bio;
            requestDict[@"name"]        = name;
            requestDict[@"longitude"]   = _longitude;
            requestDict[@"latitude"]    = _latitude;
            
            [[RYServices sharedInstance] registerUserWithPOSTDict:requestDict avatar:[UIImage imageNamed:@"patrickCarney"] forDelegate:self];
            //[[RYServices sharedInstance] submitPOST:kRegistrationAction withDict:requestDict forDelegate:self];
            
            [self showHUDWithTitle:@"Registering"];
        }
        else
        {
            [self showHUDWithTitle:@"Locating"];
        }
    }
}



#pragma mark -
#pragma mark - POSTDelegate

- (void) connectionFailed
{
    
}
- (void) postFailed
{
    [self hideHUD];
    BlockAlertView *postWarning = [[BlockAlertView alloc] initWithTitle:@"Post Error" message:@"Something went wrong connecting to our service.." delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
    [postWarning show];
}
- (void) postSucceeded:(id)response
{
    NSLog(@"Success: %@",response);
    [self hideHUD];
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

#pragma mark -
#pragma mark - LocationDelegate

- (void) locationSuceededWithLat:(NSNumber*)latitude Long:(NSNumber*)longitude
{
    [self hideHUD];
    [self setLongitude:longitude];
    [self setLatitude:latitude];
}
- (void) locationFailedWithError:(NSError*)error
{
    [self hideHUD];
    BlockAlertView *locationWarning = [[BlockAlertView alloc] initWithTitle:@"Could Not Locate" message:@"Location services are necessary for proper functioning." delegate:nil cancelButtonTitle:@"Go Without" otherButtonTitles:@"Try Again",nil];
    [locationWarning setClickedButtonBlock:^(BlockAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            [[RYLocationServices sharedInstance] requestLocationCoordinatesForDelegate:self];
        }
    }];
    [locationWarning show];
}

#pragma mark - TextFields

- (void)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark user's photo stuff

- (void)avatarTapped:(id)sender
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"No camera detected!");
        [self pickPhoto];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo",@"Pick from Photo Library", nil];
    [actionSheet showInView:self.view];
}

-(UIImagePickerController *) imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

-(void) takePhoto
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.navigationController presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void) pickPhoto
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (self.imagePicker == nil) {
        NSLog(@"It's nil!");
    }
    else
    {
        NSLog(@"Not nil!");
    }
    
    [self.navigationController presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    _avatarImageView = info[UIImagePickerControllerOriginalImage];
    CGFloat avatarSize = 100.f;
    [_avatarImageView setImage:[_avatarImage createThumbnailToFillSize:CGSizeMake(avatarSize, avatarSize)]];
    [self.avatarImageView setImage:_avatarImage];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    
    switch (buttonIndex) {
        case 0:
            [self takePhoto];
            break;
        case 1:
            [self pickPhoto];
            break;
    }
}


@end
