//
//  UIViewController+Extras.m
//  LSATMax
//
//  Created by Jason Loewy on 7/20/12.
//  Copyright (c) 2012 Jason Loewy. All rights reserved.
//

#import "Ryff-Swift.h"

#import "UIViewController+Extras.h"

// Custom UI
#import "MBProgressHUD.h"

// Categories
#import "UIImage+Thumbnail.h"

// Associated View Controllers
#import "RYRiffCreateOldViewController.h"

#define kHudTag 1912984

@implementation UIViewController (Extras)

#pragma mark -
#pragma mark - Navigation

- (void) addNewPostButtonToNavBar
{
    if (self.navigationItem)
    {
        UIBarButtonItem *newPostButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"create"] style:UIBarButtonItemStylePlain target:self action:@selector(newPost:)];
        [self.navigationItem setRightBarButtonItem:newPostButton];
    }
}

- (void) newPost:(id)sender
{
    RYRiffCreateContainerViewController *riffCreateVC = [[UIStoryboard storyboardWithName:@"RiffCreate" bundle:NULL] instantiateViewControllerWithIdentifier:@"RiffCreateContainer"];
    [self presentViewController:riffCreateVC animated:YES completion:nil];
}

#pragma mark -
#pragma mark - HUD Methods

/*
 Generalized initialization method for initing a MBProgressHUD
 RETURN
 an initialized MBProgressHUD that has already been added to its associated view
 */
- (MBProgressHUD*) initializeAndAddHud
{
    // The hud will disable all input on the view (use the higest view possible in the view hierarchy)
    UIView* viewToAddToo = (self.navigationController) ? self.navigationController.view: self.view;
    MBProgressHUD *hud   = [[MBProgressHUD alloc] initWithView:viewToAddToo];
    [viewToAddToo addSubview:hud];
    
    return hud;
}

/*
 Create a 'loading' HUD in sender view controller, must be removed from view controller by calling hideHUD
 PARAMETERS:
 -title: text for HUD
 RETURN: none
 */
- (void) showHUDWithTitle:(NSString*) title
{
    MBProgressHUD* hud = [self initializeAndAddHud];
	
	// Regiser for HUD callbacks so we can remove it from the window at the right time
	[hud setLabelText:title];
    [hud setDelegate:nil];
	[hud setTag:kHudTag];
	[hud show:YES];
}

/*
 Create a 'check' HUD in sender view controller, will remove self after duration
 PARAMETERS:
 -title: text for HUD
 -duration: duration until remove self
 RETURN: none
 */
- (void) showCheckHUDWithTitle:(NSString *)title forDuration:(NSTimeInterval)duration
{
    MBProgressHUD *hud = [self initializeAndAddHud];
    
    // The hud will disable all input on the view (use the higest view possible in the view hierarchy)
    [hud setLabelText:title];
    
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
	hud.customView = imageView;
	hud.mode = MBProgressHUDModeCustomView;
	[hud show:YES];
    [hud hide:YES afterDelay:duration];
}

/*
 Remove HUD from sender view controller
 */
- (void) hideHUD
{
    MBProgressHUD* hud;
    if (self.navigationController)
    {
        hud = (MBProgressHUD*)[self.navigationController.view viewWithTag:kHudTag];
    }
    else
        hud = (MBProgressHUD*)[self.view viewWithTag:kHudTag];
    
    if (hud)
        [hud removeFromSuperview];
}

@end
