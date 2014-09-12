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

// Data Objects
#import "RYUser.h"
#import "RYTag.h"

// Frameworks
#import "SSKeychain.h"
#import "AFHTTPRequestOperationManager.h"
#import "SGImageCache.h"

@implementation RYRegistrationServices

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
        [SSKeychain setPassword:password forService:@"ryff" account:username];
}

#pragma mark -
#pragma mark - Registration

- (void) registerUserWithPOSTDict:(NSDictionary*)params forDelegate:(id<UpdateUserDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kRegistrationAction];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            
            if (dictionary[@"success"])
            {
                [self setLoggedInUser:dictionary[@"user"] username:params[@"username"] password:params[@"password"]];
                [delegate updateSucceeded:[RYUser userFromDict:dictionary[@"user"]]];
                [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInNotification object:nil];
            }
            else
                [delegate updateFailed:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [delegate updateFailed:[error localizedDescription]];
        }];
    });
}

- (void) logInUserWithUsername:(NSString*)username Password:(NSString*)password forDelegate:(id<UpdateUserDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kLogIn];
        
        NSDictionary *params = @{@"auth_username":username,@"auth_password":password};
        
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            
            if (dictionary[@"success"])
            {
                [self setLoggedInUser:dictionary[@"user"] username:username password:password];
                [delegate updateSucceeded:[RYUser userFromDict:dictionary[@"user"]]];
                
                // register for push notifications
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInNotification object:nil];
            }
            else
                [delegate updateFailed:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [delegate updateFailed:[error localizedDescription]];
        }];
    });
}

/*
 Try logging in with saved information, if available
 */
- (BOOL) attemptBackgroundLogIn
{
    BOOL success = NO;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    NSString *password = [SSKeychain passwordForService:@"ryff" account:userObject.username];
    
    if (userObject.username && password)
    {
        success = YES;
        [self logInUserWithUsername:userObject.username Password:password forDelegate:nil];
    }
    return success;
}

- (void) logOut
{
    [SSKeychain deletePasswordForService:@"ryff" account:[RYRegistrationServices loggedInUser].username];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoggedInUserKey];
    _loggedInUser = nil;
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    while (cookieStorage.cookies.count > 0)
    {
        [cookieStorage deleteCookie:[cookieStorage.cookies firstObject]];
    }
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
                [SGImageCache removeImageForURL:[RYRegistrationServices loggedInUser].avatarURL.absoluteString];
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
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
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
        
        if (params.count > 0)
        {
            [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dictionary = responseObject;
                
                if (dictionary[@"success"])
                {
                    [self setLoggedInUser:dictionary[@"user"] username:user.username password:nil];
                    if (delegate && [delegate respondsToSelector:@selector(updateSucceeded:)])
                        [delegate updateSucceeded:[RYUser userFromDict:dictionary[@"user"]]];
                }
                else if (delegate && [delegate respondsToSelector:@selector(updateFailed:)])
                    [delegate updateFailed:responseObject];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (delegate && [delegate respondsToSelector:@selector(updateFailed:)])
                    [delegate updateFailed:[error localizedDescription]];
            }];
        }
    });
}

@end
