//
//  RYServices.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

// NSNotifications
#define kLoggedInNotification   @"userLoggedIn"

// NSUserDefaults keys
#define kLoggedInUserKey        @"loggedInUser"
#define kCoordLongitude         @"lastUpdatedLongitude"
#define kCoordLatitude          @"lastUpdatedLatitude"

// Server paths
#define kApiRoot                @"https://ryff.me/api/"

// Registration
#define kRegistrationAction     @"create-user.php"
#define kUpdateUserAction       @"update-user.php"
#define kLogIn                  @"login.php"

// Users
#define kGetPeople              @"get-user.php"
#define kGetNearby              @"get-users-nearby.php"
#define kGetFollowersAction     @"get-following.php"

// Posts
#define kGetPosts               @"get-posts.php"
#define kGetStarredPosts        @"get-starred-posts.php"
#define kGetNewsfeedPosts       @"get-news-feed.php"
#define kGetPostFamily          @"get-post-family.php"
#define kSearchPostsNew         @"search-posts-new.php"
#define kSearchPostsTop         @"search-posts-top.php"
#define kSearchPostsTrending    @"search-posts-trending.php"

// Actions
#define kFollowUserAction       @"follow.php"
#define kUnfollowUserAction     @"unfollow.php"
#define kPostRiffAction         @"add-post.php"
#define kDeletePostAction       @"delete-post.php"
#define kUpvotePostAction       @"add-upvote.php"
#define kDeleteUpvoteAction     @"delete-upvote.php"
#define kStarPostAction         @"add-star.php"
#define kUnstarPostAction       @"delete-star.php"

@class RYNewsfeedPost;
@class RYUser;

typedef enum : NSUInteger {
    NEW,
    TOP,
    TRENDING
} SearchType;

typedef enum : NSUInteger {
    CHILDREN,
    PARENTS,
} FamilyType;

@protocol PostDelegate <NSObject>
- (void) postSucceeded:(NSArray*)posts;
@optional
- (void) postFailed:(NSString*)reason;
@end

@protocol FamilyPostDelegate <NSObject>
- (void) childrenRetrieved:(NSArray *)childPosts;
- (void) parentsRetrieved:(NSArray *)parentPosts;
@optional
- (void) familyPostFailed:(NSString *)reason;
@end

@protocol UsersDelegate <NSObject>
- (void) retrievedUsers:(NSArray*)users;
@optional
- (void) retrieveUsersFailed:(NSString *)reason;
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

@protocol ActionDelegate <NSObject>
- (void) upvoteSucceeded:(RYNewsfeedPost*)updatedPost;
- (void) starSucceeded:(RYNewsfeedPost *)updatedPost;
@optional
- (void) upvoteFailed:(NSString*)reason post:(RYNewsfeedPost *)oldPost;
- (void) starFailed:(NSString *)reason post:(RYNewsfeedPost *)oldPost;
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

// Users
- (void) getFollowersForUser:(NSInteger)userID page:(NSNumber *)page delegate:(id<UsersDelegate>)delegate;

// Discover
- (void) follow:(BOOL)shouldFollow user:(NSInteger)userId forDelegate:(id<FollowDelegate>)delegate;

// Posts
- (void) postRiffWithContent:(NSString*)content title:(NSString *)title duration:(NSNumber *)duration parentIDs:(NSArray *)parentIDs image:(UIImage *)image ForDelegate:(id<RiffDelegate>)riffDelegate;
- (void) getUserPostsForUser:(NSInteger)userId page:(NSNumber *)page delegate:(id<PostDelegate>)delegate;
- (void) getNewsfeedPosts:(SearchType)searchType page:(NSNumber *)page delegate:(id<PostDelegate>)delegate;
- (void) getPostsForTags:(NSArray *)tags searchType:(SearchType)searchType page:(NSNumber *)page delegate:(id<PostDelegate>)delegate;
- (void) getStarredPostsForUser:(NSInteger)userID delegate:(id<PostDelegate>)delegate;

// Actions
- (void) upvote:(BOOL)shouldUpvote post:(RYNewsfeedPost *)post forDelegate:(id<ActionDelegate>)delegate;
- (void) star:(BOOL)shouldStar post:(RYNewsfeedPost *)post forDelegate:(id<ActionDelegate>)delegate;
- (void) getFamilyForPost:(NSInteger)postID delegate:(id<FamilyPostDelegate>)delegate;

@end
