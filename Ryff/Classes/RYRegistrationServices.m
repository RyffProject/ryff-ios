//
//  RYRegistrationServices.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/8/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRegistrationServices.h"

// Data Managers
#import "RYServices.h"
#import "RYNotificationsManager.h"

// Data Objects
#import "RYUser.h"
#import "RYTag.h"

// Frameworks
@import SSKeychain;
#import "AFHTTPRequestOperationManager.h"
#import "SDWebImageManager.h"

@implementation RYRegistrationServices

static NSString *ryffServiceName = @"ryff";
static NSString *userKey = @"auth_username";
static NSString *passwordKey = @"auth_password";

static RYRegistrationServices* _sharedInstance;
static RYUser* _loggedInUser;

+ (RYRegistrationServices *)sharedInstance
{
    if (_sharedInstance == NULL)
    {
        _sharedInstance = [RYRegistrationServices allocWithZone:NULL];
    }
    return _sharedInstance;
}

+ (RYUser *)loggedInUser
{
    if (_loggedInUser == NULL)
    {
        NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
        if (userDict)
            _loggedInUser = [RYUser userFromDict:userDict];
    }
    return _loggedInUser;
}

- (void) setLoggedInUser:(NSDictionary *)userDict username:(NSString *)username password:(NSString *)password
{
    [[NSUserDefaults standardUserDefaults] setObject:userDict forKey:kLoggedInUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (password && password.length > 0)
        [SSKeychain setPassword:password forService:ryffServiceName account:username];
}

- (BOOL) attemptBackgroundLogIn
{
    // TEST
    [self logInUserWithUsername:@"trachytoid" Password:@"password" forDelegate:nil];
    return YES;
    // TEST
    
    BOOL success = NO;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    NSString *password = [SSKeychain passwordForService:ryffServiceName account:userObject.username];
    
    if (userObject.username && password)
    {
        success = YES;
        [self logInUserWithUsername:userObject.username Password:password forDelegate:nil];
    }
    return success;
}

- (void) logOut
{
    [SSKeychain deletePasswordForService:ryffServiceName account:[RYRegistrationServices loggedInUser].username];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoggedInUserKey];
    _loggedInUser = nil;
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    while (cookieStorage.cookies.count > 0)
    {
        [cookieStorage deleteCookie:[cookieStorage.cookies firstObject]];
    }
}

#pragma mark -
#pragma mark - Registration

- (void) updateUserWithParams:(NSDictionary *)params toAction:(NSString *)action forDelegate:(id<UpdateUserDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            
            if (dictionary[@"success"])
            {
                [self setLoggedInUser:dictionary[@"user"] username:params[userKey] password:params[passwordKey]];
                [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInNotification object:nil];
                
                if (delegate && [delegate respondsToSelector:@selector(updateSucceeded:)])
                    [delegate updateSucceeded:[RYUser userFromDict:dictionary[@"user"]]];
            }
            else if (delegate && [delegate respondsToSelector:@selector(updateFailed:)])
                [delegate updateFailed:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (delegate && [delegate respondsToSelector:@selector(updateFailed:)])
                [delegate updateFailed:[error localizedDescription]];
        }];
    });
}

- (void) registerUserWithPOSTDict:(NSDictionary*)params forDelegate:(id<UpdateUserDelegate>)delegate
{
    NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kRegistrationAction];
    [self updateUserWithParams:params toAction:action forDelegate:delegate];
}

- (void) logInUserWithUsername:(NSString*)username Password:(NSString*)password forDelegate:(id<UpdateUserDelegate>)delegate
{
    NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kLogIn];
    NSDictionary *params = @{userKey:username, passwordKey:password};
    [self updateUserWithParams:params toAction:action forDelegate:delegate];
}

#pragma mark -
#pragma mark - Edit User

- (void) updateAvatar:(UIImage*)avatar forDelegate:(id<UpdateUserDelegate>)delegate
{
    if (![RYRegistrationServices loggedInUser])
        return;
    
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kUpdateUserAction];
        
        [manager POST:action parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            if (avatar)
            {
                NSData *imageData = UIImagePNGRepresentation(avatar);
                [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"avatar" mimeType:@"image/png"];
            }
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            
            if (dictionary[@"success"])
            {
                RYUser *updatedUser = [RYUser userFromDict:dictionary[@"user"]];
                [[SDWebImageManager sharedManager] saveImageToCache:avatar forURL:[RYRegistrationServices loggedInUser].avatarURL];
                [delegate updateSucceeded:updatedUser];
            }
            else
                [delegate updateFailed:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [delegate updateFailed:[error localizedDescription]];
        }];
    });
}

- (void) editUserInfo:(RYUser*)user forDelegate:(id<UpdateUserDelegate>)delegate
{
    NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kUpdateUserAction];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    RYUser *oldUser = [RYRegistrationServices loggedInUser];
    if (user.username && ![user.username isEqualToString:oldUser.username])
        [params setObject:user.username forKey:@"username"];
    if (user.nickname && ![user.nickname isEqualToString:oldUser.nickname])
        [params setObject:user.nickname forKey:@"name"];
    if (user.bio && ![user.bio isEqualToString:oldUser.bio])
        [params setObject:user.bio forKey:@"bio"];
    if (user.email && ![user.email isEqualToString:oldUser.email])
        [params setObject:user.email forKey:@"email"];
    if (user.tags && ![user.tags isEqualToArray:oldUser.tags])
    {
        // can't send empty array via POST, send empty string
        NSArray *tags = [RYTag getTagTags:user.tags];
        if (tags.count > 0)
            [params setObject:[RYTag getTagTags:user.tags] forKey:@"tags"];
        else
            [params setObject:@"" forKey:@"tags"];
    }
    [self updateUserWithParams:params toAction:action forDelegate:delegate];
}

@end
