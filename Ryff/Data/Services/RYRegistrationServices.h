//
//  RYRegistrationServices.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/8/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RYServices.h"

// NSNotifications
#define kLoggedInNotification   @"userLoggedIn"

// NSUserDefaults keys
#define kLoggedInUserKey        @"loggedInUser"
#define kCoordLongitude         @"lastUpdatedLongitude"
#define kCoordLatitude          @"lastUpdatedLatitude"

// Registration
#define kRegistrationAction     @"create-user.php"
#define kUpdateUserAction       @"update-user.php"
#define kLogIn                  @"login.php"

@class RYUser;

@protocol UpdateUserDelegate <NSObject>
- (void) updateSucceeded:(RYUser*)user;
@optional
- (void) updateFailed:(NSString*)reason;
@end

@interface RYRegistrationServices : NSObject

+ (RYRegistrationServices *)sharedInstance;
+ (RYUser *) loggedInUser;

// Registration
- (void) registerUserWithPOSTDict:(NSDictionary*)params forDelegate:(id<UpdateUserDelegate>)delegate;
- (void) logInUserWithUsername:(NSString*)username Password:(NSString*)password forDelegate:(id<UpdateUserDelegate>)delegate;
- (BOOL) attemptBackgroundLogIn;
- (void) logOut;

// Edit User
- (void) updateAvatar:(UIImage*)avatar forDelegate:(id<UpdateUserDelegate>)delegate;
- (void) editUserInfo:(RYUser*)user forDelegate:(id<UpdateUserDelegate>)delegate;

@end
