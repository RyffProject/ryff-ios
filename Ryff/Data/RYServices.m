//
//  RYServices.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYServices.h"

// Data Managers
#import "RYDataManager.h"

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
                RYUser *updatedUser = [RYUser userFromDict:dictionary[@"user"]];
                [SGImageCache removeImageForURL:updatedUser.avatarURL];
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
        
        RYUser *oldUser = [RYServices loggedInUser];
        if (user.username && ![user.username isEqualToString:oldUser.username])
            [params setObject:user.username forKey:@"username"];
        if (user.nickname && ![user.nickname isEqualToString:oldUser.nickname])
            [params setObject:user.nickname forKey:@"name"];
        if (user.bio && ![user.bio isEqualToString:oldUser.bio])
            [params setObject:user.bio forKey:@"bio"];
        if (user.email && ![user.email isEqualToString:oldUser.email])
            [params setObject:user.email forKey:@"email"];
        
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
- (void) follow:(NSInteger)userId forDelegate:(id<FollowDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{

        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSDictionary *params = @{@"id":@(userId)};

        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kAddFriendAction];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
                [delegate followConfirmed:userId];
            else
                [delegate followFailed];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Post error: %@",[error localizedDescription]);
            [delegate followFailed];
        }];
    });
}
- (void) unfollow:(NSInteger)userId forDelegate:(id<FollowDelegate>)delegate
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
                [delegate unfollowConfirmed:userId];
            else
                [delegate followFailed];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Post error: %@",[error localizedDescription]);
            [delegate followFailed];
        }];
    });
}

#pragma mark -
#pragma mark - Newsfeed

- (void) postRiffWithContent:(NSString*)content title:(NSString *)title duration:(NSNumber *)duration parentIDs:(NSArray *)parentIDs ForDelegate:(id<RiffDelegate>)riffDelegate
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
                
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSMutableDictionary *params = [@{@"id":@(userObject.userId)} mutableCopy];
        
        if (content)
            [params setObject:content forKey:@"content"];
        if (title)
            [params setObject:title forKey:@"title"];
        if (duration)
            [params setObject:duration forKey:@"duration"];
        if (parentIDs)
            [params setObject:parentIDs forKey:@"parent_ids"];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kPostRiffAction];
        [manager POST:action parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[[RYDataManager urlForRiff] path]])
            {
                NSData *musicData = [NSData dataWithContentsOfFile:[[RYDataManager urlForRiff] path]];
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

- (void) getUserPostsForUser:(NSInteger)userId Delegate:(id<PostDelegate>)delegate
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
                {
                    NSArray *posts = [RYNewsfeedPost newsfeedPostsFromDictArray:dictionary[@"posts"]];
                    [delegate postSucceeded:posts];
                }
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

- (void) getNewsfeedPostsForDelegate:(id<PostDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kGetNewsfeedPosts];
        [manager POST:action parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
            {
                NSArray *posts = [RYNewsfeedPost newsfeedPostsFromDictArray:dictionary[@"posts"]];
                [delegate postSucceeded:posts];
            }
            else if (delegate && [delegate respondsToSelector:@selector(postFailed:)])
                [delegate postFailed:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (delegate && [delegate respondsToSelector:@selector(postFailed:)])
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



- (void) getFamilyForPost:(NSInteger)postID delegate:(id<PostDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSDictionary *params = @{@"id":@(postID)};
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kGetPostFamily];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
            {
                NSArray *posts = [RYNewsfeedPost newsfeedPostsFromDictArray:dictionary[@"posts"]];
                [delegate postSucceeded:posts];
            }
            else
                [delegate postFailed:dictionary[@"error"]];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [delegate postFailed:[error localizedDescription]];
        }];
    });
}

@end