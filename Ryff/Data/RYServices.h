//
//  RYServices.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

// NSUserDefaults keys
#define kLoggedInUserKey    @"loggedInUser"
#define kCoordLongitude     @"lastUpdatedLongitude"
#define kCoordLatitude      @"lastUpdatedLatitude"

// Server paths
#define kApiRoot            @"https://ryff.me/api/"
#define kLogIn              @"login.php"
#define kRegistrationAction @"create-user.php"
#define kUpdateUserAction   @"update-user.php"
#define kAddFriendAction    @"follow.php"
#define kDeleteFriendAction @"unfollow.php"
#define kPostRiffAction     @"add-post.php"
#define kUpvotePostAction   @"add-upvote.php"
#define kDeleteUpvoteAction @"delete-upvote.php"
#define kDeletePostAction   @"delete-post.php"
#define kGetPostFamily      @"get-post-family.php"
#define kGetPosts           @"get-posts.php"
#define kGetPeople          @"get-user.php"
#define kGetNearby          @"get-users-nearby.php"
#define kGetNewsfeedPosts   @"get-news-feed.php"

@class RYNewsfeedPost;
@class RYUser;

@protocol PostDelegate <NSObject>
- (void) postSucceeded:(NSArray*)posts;
@optional
- (void) postFailed:(NSString*)reason;
@end

@protocol ArtistsFetchDelegate <NSObject>
- (void) retrievedArtists:(NSArray*)artists;
@end

@protocol FollowDelegate <NSObject>
- (void) followConfirmed:(NSInteger)userID;
- (void) unfollowConfirmed:(NSInteger)userID;
@optional
- (void) followFailed;
@end

@protocol RiffDelegate <NSObject>
- (void) riffPostSucceeded;
@optional
- (void) riffPostFailed;
@end

@protocol UpvoteDelegate <NSObject>
- (void) upvoteSucceeded:(RYNewsfeedPost*)updatedPost;
@optional
- (void) upvoteFailed:(NSString*)reason;
@end

@protocol UpdateUserDelegate <NSObject>
- (void) updateSucceeded:(RYUser*)user;
@optional
- (void) updateFailed:(NSString*)reason;
@end

@class RYUser;
@class RYNewsfeedPost;

@interface RYServices : NSObject

+ (RYServices *)sharedInstance;
+ (RYUser *) loggedInUser;

// Registration
- (void) registerUserWithPOSTDict:(NSDictionary*)params forDelegate:(id<UpdateUserDelegate>)delegate;
- (void) logInUserWithUsername:(NSString*)username Password:(NSString*)password forDelegate:(id<UpdateUserDelegate>)delegate;
- (BOOL) attemptBackgroundLogIn;
- (void) logOut;

// Edit User
- (void) updateAvatar:(UIImage*)avatar forDelegate:(id<UpdateUserDelegate>)delegate;
- (void) editUserInfo:(RYUser*)user forDelegate:(id<UpdateUserDelegate>)delegate;
- (void) deletePost:(RYNewsfeedPost*)post;

// Discover
@property (nonatomic, weak) id <ArtistsFetchDelegate> artistsDelegate;
- (void) moreArtistsOfCount:(NSInteger)numArtists;
- (void) follow:(NSInteger)userId forDelegate:(id<FollowDelegate>)delegate;
- (void) unfollow:(NSInteger)userId forDelegate:(id<FollowDelegate>)delegate;

// Posts
- (void) postRiffWithContent:(NSString*)content title:(NSString *)title duration:(NSNumber *)duration parentIDs:(NSArray *)parentIDs ForDelegate:(id<RiffDelegate>)riffDelegate;
- (void) getUserPostsForUser:(NSInteger)userId Delegate:(id<PostDelegate>)delegate;
- (void) getNewsfeedPostsForDelegate:(id<PostDelegate>)delegate;
- (void) upvote:(BOOL)shouldUpvote post:(NSInteger)postID forDelegate:(id<UpvoteDelegate>)delegate;
- (void) getFamilyForPost:(NSInteger)postID delegate:(id<PostDelegate>)delegate;

@end
