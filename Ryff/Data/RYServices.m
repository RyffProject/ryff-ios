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
                [SGImageCache removeImageForURL:[RYServices loggedInUser].avatarURL];
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
        if (user.tags && ![user.tags isEqualToArray:oldUser.tags])
            [params setObject:user.tags forKey:@"tags"];
        
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
#pragma mark - Discover

- (void) follow:(BOOL)shouldFollow user:(NSInteger)userId forDelegate:(id<FollowDelegate>)delegate
{
    if (![RYServices loggedInUser])
        return;
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserKey];
    RYUser *userObject = [RYUser userFromDict:userDict];
    
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

        NSDictionary *params = @{@"id":@(userObject.userId)};
        
        NSString *action = shouldFollow ? [NSString stringWithFormat:@"%@%@",kApiRoot,kFollowUserAction] : [NSString stringWithFormat:@"%@%@",kApiRoot,kUnfollowUserAction];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
            {
                if (delegate && [delegate respondsToSelector:@selector(unfollowConfirmed:)])
                    [delegate unfollowConfirmed:userId];
            }
            else if (delegate && [delegate respondsToSelector:@selector(followFailed)])
                [delegate followFailed];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (delegate && [delegate respondsToSelector:@selector(followFailed)])
                [delegate followFailed];
        }];
    });
}

#pragma mark -
#pragma mark - Posts

- (void) postRiffWithContent:(NSString*)content title:(NSString *)title duration:(NSNumber *)duration parentIDs:(NSArray *)parentIDs image:(UIImage *)image ForDelegate:(id<RiffDelegate>)riffDelegate
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
            
            if (image)
            {
                NSData *imageData = UIImagePNGRepresentation(image);
                [formData appendPartWithFileData:imageData name:@"image" fileName:@"image" mimeType:@"image/png"];
            }
            
        }  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            
            if (dictionary[@"success"])
            {
                if (riffDelegate && [riffDelegate respondsToSelector:@selector(riffPostSucceeded)])
                    [riffDelegate riffPostSucceeded];
            }
            else if (riffDelegate && [riffDelegate respondsToSelector:@selector(riffPostFailed)])
                [riffDelegate riffPostFailed];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (riffDelegate && [riffDelegate respondsToSelector:@selector(riffPostFailed)])
                [riffDelegate riffPostFailed];
        }];
    });
}

- (void) getUserPostsForUser:(NSInteger)userId page:(NSNumber *)page delegate:(id<PostDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
        [params setObject:@(userId) forKey:@"id"];
        if (page)
            [params setObject:page forKey:@"page"];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kGetPosts];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
            {
                if (delegate && [delegate respondsToSelector:@selector(postSucceeded:)])
                {
                    NSArray *posts = [RYNewsfeedPost newsfeedPostsFromDictArray:dictionary[@"posts"]];
                    [delegate postSucceeded:posts];
                }
            }
            else if (delegate && [delegate respondsToSelector:@selector(postFailed:)])
                [delegate postFailed:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Post error: %@",[error localizedDescription]);
            if (delegate && [delegate respondsToSelector:@selector(postFailed:)])
                [delegate postFailed:[error localizedDescription]];
        }];
    });
}

- (void) getNewsfeedPosts:(SearchType)searchType page:(NSNumber *)page delegate:(id<PostDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *action;
        switch (searchType) {
            case NEW:
                action = [NSString stringWithFormat:@"%@%@",kApiRoot,kSearchPostsNew];
                break;
            case TOP:
                action = [NSString stringWithFormat:@"%@%@",kApiRoot,kSearchPostsTop];
                break;
            case TRENDING:
                action = [NSString stringWithFormat:@"%@%@",kApiRoot,kSearchPostsTrending];
                break;
            default:
                break;
        }
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:1];
        if (page)
            [params setObject:page forKey:@"page"];
        
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (void) getPostsForTags:(NSArray *)tags searchType:(SearchType)searchType page:(NSNumber *)page delegate:(id<PostDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *action;
        switch (searchType) {
            case NEW:
                action = [NSString stringWithFormat:@"%@%@",kApiRoot,kSearchPostsNew];
                break;
            case TOP:
                action = [NSString stringWithFormat:@"%@%@",kApiRoot,kSearchPostsTop];
                break;
            case TRENDING:
                action = [NSString stringWithFormat:@"%@%@",kApiRoot,kSearchPostsTrending];
                break;
            default:
                break;
        }
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
        if (tags)
            [params setObject:tags forKey:@"tags"];
        if (page)
            [params setObject:page forKey:@"page"];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
            {
                if (delegate && [delegate respondsToSelector:@selector(postSucceeded:)])
                {
                    NSArray *posts = [RYNewsfeedPost newsfeedPostsFromDictArray:dictionary[@"posts"]];
                    [delegate postSucceeded:posts];
                }
            }
            else if (delegate && [delegate respondsToSelector:@selector(postFailed:)])
                [delegate postFailed:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (delegate && [delegate respondsToSelector:@selector(postFailed:)])
                [delegate postFailed:[error localizedDescription]];
        }];
    });
}

- (void) getStarredPostsForUser:(NSInteger)userID delegate:(id<PostDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:kGetStarredPosts parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

#pragma mark -
#pragma mark - Actions

- (void) upvote:(BOOL)shouldUpvote post:(RYNewsfeedPost *)post forDelegate:(id<ActionDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSDictionary *params = @{@"id":@(post.postId)};
        
        NSString *action = shouldUpvote ? [NSString stringWithFormat:@"%@%@",kApiRoot,kUpvotePostAction] : [NSString stringWithFormat:@"%@%@",kApiRoot,kDeleteUpvoteAction];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"] && delegate)
            {
                if (delegate && [delegate respondsToSelector:@selector(upvoteSucceeded:)])
                    [delegate upvoteSucceeded:[RYNewsfeedPost newsfeedPostWithDict:dictionary[@"post"]]];
            }
            else
            {
                if (delegate && [delegate respondsToSelector:@selector(upvoteFailed:post:)])
                    [delegate upvoteFailed:dictionary[@"error"] post:post];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (delegate && [delegate respondsToSelector:@selector(upvoteFailed:post:)])
                [delegate upvoteFailed:[error localizedDescription] post:post];
        }];
    });
}

- (void) star:(BOOL)shouldStar post:(RYNewsfeedPost *)post forDelegate:(id<ActionDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSDictionary *params = @{@"id":@(post.postId)};
        
        NSString *action = shouldStar ? [NSString stringWithFormat:@"%@%@",kApiRoot,kStarPostAction] : [NSString stringWithFormat:@"%@%@",kApiRoot,kUnstarPostAction];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
            {
                if (delegate && [delegate respondsToSelector:@selector(upvoteSucceeded:)])
                    [delegate upvoteSucceeded:[RYNewsfeedPost newsfeedPostWithDict:dictionary[@"post"]]];
            }
            else
            {
                if (delegate && [delegate respondsToSelector:@selector(upvoteFailed:post:)])
                    [delegate upvoteFailed:dictionary[@"error"] post:post];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (delegate && [delegate respondsToSelector:@selector(upvoteFailed:post:)])
                [delegate upvoteFailed:[error localizedDescription] post:post];
        }];
    });
}

- (void) getFamilyForPost:(NSInteger)postID delegate:(id<FamilyPostDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSDictionary *params = @{@"id":@(postID)};
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kGetPostFamily];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
            {
                if (delegate && [delegate respondsToSelector:@selector(childrenRetrieved:)])
                    [delegate childrenRetrieved:[RYNewsfeedPost newsfeedPostsFromDictArray:dictionary[@"children"]]];
                if (delegate && [delegate respondsToSelector:@selector(parentsRetrieved:)])
                    [delegate parentsRetrieved:[RYNewsfeedPost newsfeedPostsFromDictArray:dictionary[@"parents"]]];
            }
            else
                [delegate familyPostFailed:dictionary[@"error"]];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [delegate familyPostFailed:[error localizedDescription]];
        }];
    });
}

@end