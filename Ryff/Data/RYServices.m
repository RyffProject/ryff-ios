//
//  RYServices.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYServices.h"

// Data Objects
#import "RYUser.h"
#import "RYNewsfeedPost.h"
#import "RYRiff.h"

// Data Systems
#import "SSKeychain.h"
#import "SGImageCache.h"

// Custom UI
#import "RYStyleSheet.h"

// Server
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"

@implementation RYServices

static RYServices* _sharedInstance;
static RYUser* _loggedInUser;

+ (RYServices *)sharedInstance
{
    if (_sharedInstance == NULL)
    {
        _sharedInstance = [RYServices allocWithZone:NULL];
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

#pragma mark -
#pragma mark - Registration

- (void) registerUserWithPOSTDict:(NSDictionary*)params forDelegate:(id<POSTDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kRegistrationAction];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            
            if (dictionary[@"success"])
                [delegate postSucceeded:responseObject];
            else
                [delegate postFailed:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [delegate postFailed:[error localizedDescription]];
        }];
    });
}


- (void) logInUserWithUsername:(NSString*)username Password:(NSString*)password forDelegate:(id<POSTDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kLogIn];
        
        NSDictionary *params = @{@"auth_username":username,@"auth_password":password};
        
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            
            if (dictionary[@"success"])
                [delegate postSucceeded:responseObject];
            else
                [delegate postFailed:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [delegate postFailed:[error localizedDescription]];
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
    [SSKeychain deletePasswordForService:@"ryff" account:[RYServices loggedInUser].username];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoggedInUserKey];
    _loggedInUser = nil;
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
}

#pragma mark -
#pragma mark - Edit User

- (void) updateAvatar:(UIImage*)avatar forDelegate:(id<UpdateUserDelegate>)delegate
{
    if (![RYServices loggedInUser])
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
                [SGImageCache flushImagesOlderThan:0.1];
                [delegate updateSucceeded:[RYUser userFromDict:dictionary[@"user"]]];
            }
            else
                [delegate updateFailed:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [delegate updateFailed:[error localizedDescription]];
        }];
    });
}

// not set up yet
- (void) editUserInfo:(RYUser*)user
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kUpdateUserAction];
        
        [manager POST:action parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            
            if (dictionary[@"success"])
                NSLog(@"edit succeeded");
            else
                NSLog(@"edit failed but post succeeded");
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"edit failed");
        }];
    });
}

- (void) deletePost:(RYNewsfeedPost*)post
{
    
    UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Post delete failed" message:[NSString stringWithFormat:@"Something went wrong and post was not deleted: %@",post.riff.title] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kDeletePostAction];
        
        NSDictionary *params = @{@"id" : @(post.postId)};
        
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            
            if (!dictionary[@"success"])
                [failureAlert show];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [failureAlert show];
        }];
    });
}

#pragma mark -
#pragma mark - Artist Suggester

- (void) parseArtists:(NSArray*)artistsArray
{
    NSMutableArray *objectiveArtists = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < artistsArray.count; i++)
    {
        NSDictionary *artistDict = artistsArray[i];
        RYUser *user = [RYUser userFromDict:artistDict];
        [objectiveArtists addObject:user];
    }
    
    if (_artistsDelegate)
        [_artistsDelegate retrievedArtists:objectiveArtists];
}

- (void) moreArtistsOfCount:(NSInteger)numArtists
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSDictionary *params = @{@"auth_username":userObject.username,@"id":@(userObject.userId)};
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kGetNearby];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
            {
                NSArray *artists = dictionary[@"users"];
                [self parseArtists:artists];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Post error: %@",[error localizedDescription]);
        }];
    });
}
- (void) addFriend:(NSInteger)userId forDelegate:(id<FriendsDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{

        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSDictionary *params = @{@"id":@(userId)};

        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kAddFriendAction];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
                [delegate friendConfirmed];
            else
                [delegate actionFailed];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Post error: %@",[error localizedDescription]);
            [delegate actionFailed];
        }];
    });
}
- (void) deleteFriend:(NSInteger)userId forDelegate:(id<FriendsDelegate>)delegate
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

        NSDictionary *params = @{@"id":@(userObject.userId)};
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kDeleteFriendAction];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
                [delegate friendDeleted];
            else
                [delegate actionFailed];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Post error: %@",[error localizedDescription]);
            [delegate actionFailed];
        }];
    });
}

#pragma mark -
#pragma mark - Newsfeed

+ (NSURL*)urlForRiff
{
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"riff.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    return outputFileURL;
}

- (void) postRiffWithContent:(NSString*)content title:(NSString*)title duration:(NSNumber*)duration ForDelegate:(id<RiffDelegate>)riffDelegate
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    
    if (!content)
        content = @"";
    if (!duration)
        duration = @0;
    
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
                
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                
        NSDictionary *params = @{@"id":@(userObject.userId), @"content":content, @"title":title,@"duration":duration};
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kPostRiffAction];
        [manager POST:action parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[[RYServices urlForRiff] path]])
            {
                NSData *musicData = [NSData dataWithContentsOfFile:[[RYServices urlForRiff] path]];
                [formData appendPartWithFileData:musicData name:@"riff" fileName:@"riff" mimeType:@"audio/mp4"];
            }
            
        }  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            
            if (dictionary[@"success"])
                [riffDelegate riffPostSucceeded];
            else
                [riffDelegate riffPostFailed];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [riffDelegate riffPostFailed];
        }];
    });
}

- (void) getUserPostsForUser:(NSInteger)userId Delegate:(id<POSTDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSDictionary *params = @{@"id":@(userId)};
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kGetPosts];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (delegate)
            {
                if (dictionary[@"success"])
                    [delegate postSucceeded:responseObject];
                else
                    [delegate postFailed:nil];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Post error: %@",[error localizedDescription]);
            if (delegate)
                [delegate postFailed:[error localizedDescription]];
        }];
    });
}

- (void) getFriendPostsForDelegate:(id<POSTDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kGetFriendsPosts];
        [manager POST:action parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
                [delegate postSucceeded:responseObject];
            else
                [delegate postFailed:nil];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Post error: %@",[error localizedDescription]);
            [delegate postFailed:[error localizedDescription]];
        }];
    });
}

- (void) upvote:(BOOL)shouldUpvote post:(NSInteger)postID forDelegate:(id<UpvoteDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSDictionary *params = @{@"id":@(postID)};
        
        NSString *action = shouldUpvote ? [NSString stringWithFormat:@"%@%@",kApiRoot,kUpvotePostAction] : [NSString stringWithFormat:@"%@%@",kApiRoot,kDeleteUpvoteAction];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"] && delegate)
                [delegate upvoteSucceeded:[RYNewsfeedPost newsfeedPostWithDict:dictionary[@"post"]]];
            else
                [delegate upvoteFailed:dictionary[@"error"]];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [delegate upvoteFailed:[error localizedDescription]];
        }];
    });
}

@end