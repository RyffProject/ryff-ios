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
#import "RYRegistrationServices.h"

// Data Objects
#import "RYUser.h"
#import "RYPost.h"
#import "RYTag.h"

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

- (void) deletePost:(RYPost*)post
{
//    UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Post delete failed" message:[NSString stringWithFormat:@"Something went wrong and post was not deleted: %@",post.riff.title] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kDeletePostAction];
        
        NSDictionary *params = @{@"id" : @(post.postId)};
        
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSDictionary *dictionary = responseObject;
//            
//            if (!dictionary[@"success"])
//                [failureAlert show];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [failureAlert show];
        }];
    });
}

#pragma mark -
#pragma mark - Users

- (void) getUserWithId:(NSNumber *)userID orUsername:(NSString *)username delegate:(id<UsersDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:1];
        if (userID)
            [params setObject:userID forKey:@"id"];
        else if (username)
            [params setObject:username forKey:@"username"];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kGetUser];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
            {
                if (delegate && [delegate respondsToSelector:@selector(retrievedUsers:)])
                    [delegate retrievedUsers:@[[RYUser userFromDict:dictionary[@"user"]]]];
            }
            else
            {
                if (delegate && [delegate respondsToSelector:@selector(retrieveUsersFailed:)])
                    [delegate retrieveUsersFailed:dictionary[@"error"]];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (delegate && [delegate respondsToSelector:@selector(retrieveUsersFailed:)])
                [delegate retrieveUsersFailed:[error localizedDescription]];
        }];
    });
}

- (void) getFollowersForUser:(NSInteger)userID page:(NSNumber *)page delegate:(id<UsersDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSMutableDictionary *params = [@{@"id":@(userID)} mutableCopy];
        if (page)
            [params setObject:page forKey:@"page"];
        
        NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kGetFollowersAction];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
            {
                if (delegate && [delegate respondsToSelector:@selector(retrievedUsers:)])
                    [delegate retrievedUsers:[RYUser usersFromDictArray:dictionary[@"users"]]];
            }
            else
            {
                if (delegate && [delegate respondsToSelector:@selector(retrieveUsersFailed:)])
                    [delegate retrieveUsersFailed:dictionary[@"error"]];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (delegate && [delegate respondsToSelector:@selector(retrieveUsersFailed:)])
                [delegate retrieveUsersFailed:[error localizedDescription]];
        }];
    });
}

#pragma mark -
#pragma mark - Discover

- (void) follow:(BOOL)shouldFollow user:(NSInteger)userId forDelegate:(id<FollowDelegate>)delegate
{
    if (![RYRegistrationServices loggedInUser])
        return;
    
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

        NSDictionary *params = @{@"id":@(userId)};
        
        NSString *action = shouldFollow ? [NSString stringWithFormat:@"%@%@",kApiRoot,kFollowUserAction] : [NSString stringWithFormat:@"%@%@",kApiRoot,kUnfollowUserAction];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
            {
                if (delegate && [delegate respondsToSelector:@selector(follow:confirmedForUser:)])
                    [delegate follow:shouldFollow confirmedForUser:[RYUser userFromDict:dictionary[@"user"]]];
            }
            else if (delegate && [delegate respondsToSelector:@selector(followFailed:)])
                [delegate followFailed:dictionary[@"error"]];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (delegate && [delegate respondsToSelector:@selector(followFailed:)])
                [delegate followFailed:[error localizedDescription]];
        }];
    });
}

#pragma mark -
#pragma mark - Posts

- (void) postRiffWithContent:(NSString*)content title:(NSString *)title duration:(NSNumber *)duration parentIDs:(NSArray *)parentIDs image:(UIImage *)image ForDelegate:(id<RiffDelegate>)riffDelegate
{
    if (![RYRegistrationServices loggedInUser])
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

- (void) getPostsWithParams:(NSDictionary *)params toAction:(NSString *)action page:(NSNumber *)page forDelegate:(id<PostDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        NSMutableDictionary *mutParams = params ? [params mutableCopy] : [[NSMutableDictionary alloc] initWithCapacity:1];
        if (page)
            mutParams[@"page"] = page;
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:action parameters:mutParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
            {
                if (delegate && [delegate respondsToSelector:@selector(postSucceeded:page:)])
                    [delegate postSucceeded:[RYPost postsFromDictArray:dictionary[@"posts"]] page:page];
            }
            else if (delegate && [delegate respondsToSelector:@selector(postFailed:page:)])
                [delegate postFailed:responseObject page:page];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Post error: %@",[error localizedDescription]);
            if (delegate && [delegate respondsToSelector:@selector(postFailed:page:)])
                [delegate postFailed:[error localizedDescription] page:page];
        }];
    });
}

- (void) getUserPostsForUser:(NSInteger)userId page:(NSNumber *)page delegate:(id<PostDelegate>)delegate
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    [params setObject:@(userId) forKey:@"id"];
    
    NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kGetPosts];
    [self getPostsWithParams:params toAction:action page:page forDelegate:delegate];
}

- (void) getNewsfeedPostsWithPage:(NSNumber *)page delegate:(id<PostDelegate>)delegate
{
    NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kGetNewsfeedPosts];
    [self getPostsWithParams:nil toAction:action page:page forDelegate:delegate];
}

- (void) getPostsForTags:(NSArray *)tags searchType:(SearchType)searchType page:(NSNumber *)page limit:(NSNumber *)limit delegate:(id<PostDelegate>)delegate
{
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
    if (limit)
        [params setObject:limit forKey:@"limit"];
    
    [self getPostsWithParams:params toAction:action page:page forDelegate:delegate];
}

- (void) getStarredPostsForUser:(NSInteger)userID delegate:(id<PostDelegate>)delegate
{
    NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kGetStarredPosts];
    [self getPostsWithParams:nil toAction:action page:nil forDelegate:delegate];
}

#pragma mark -
#pragma mark - Actions

- (void) upvote:(BOOL)shouldUpvote post:(RYPost *)post forDelegate:(id<ActionDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSDictionary *params = @{@"id":@(post.postId)};
        
        NSString *action = shouldUpvote ? [NSString stringWithFormat:@"%@%@",kApiRoot,kUpvotePostAction] : [NSString stringWithFormat:@"%@%@",kApiRoot,kDeleteUpvoteAction];
        [manager POST:action parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
            {
                if (delegate && [delegate respondsToSelector:@selector(upvoteSucceeded:)])
                    [delegate upvoteSucceeded:[RYPost postWithDict:dictionary[@"post"]]];
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

- (void) star:(BOOL)shouldStar post:(RYPost *)post forDelegate:(id<ActionDelegate>)delegate
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
                    [delegate upvoteSucceeded:[RYPost postWithDict:dictionary[@"post"]]];
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
                    [delegate childrenRetrieved:[RYPost postsFromDictArray:dictionary[@"children"]]];
                if (delegate && [delegate respondsToSelector:@selector(parentsRetrieved:)])
                    [delegate parentsRetrieved:[RYPost postsFromDictArray:dictionary[@"parents"]]];
            }
            else if (delegate && [delegate respondsToSelector:@selector(familyPostFailed:)])
                [delegate familyPostFailed:dictionary[@"error"]];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (delegate && [delegate respondsToSelector:@selector(familyPostFailed:)])
                [delegate familyPostFailed:[error localizedDescription]];
        }];
    });
}

@end