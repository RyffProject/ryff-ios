//
//  RYServices.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Server paths
#define kApiRoot                @"http://ryff.chrislaganiere.net/api/"

// Users
#define kGetUser                @"get-user.php"
#define kGetNearby              @"get-users-nearby.php"
#define kGetFollowersAction     @"get-followers.php"

// Posts
#define kGetPosts               @"get-posts.php"
#define kGetStarredPosts        @"get-starred-posts.php"
#define kGetNewsfeedPosts       @"get-news-feed.php"
#define kGetPostFamily          @"get-post-family.php"
#define kSearchPostsNew         @"search-posts-new.php"
#define kSearchPostsTop         @"search-posts-top.php"
#define kSearchPostsTrending    @"search-posts-trending.php"

// Actions
#define kFollowUserAction       @"add-follow.php"
#define kUnfollowUserAction     @"delete-follow.php"
#define kPostRiffAction         @"add-post.php"
#define kDeletePostAction       @"delete-post.php"
#define kUpvotePostAction       @"add-upvote.php"
#define kDeleteUpvoteAction     @"delete-upvote.php"
#define kStarPostAction         @"add-star.php"
#define kUnstarPostAction       @"delete-star.php"

@class RYPost;
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
- (void) postSucceeded:(NSArray*)posts page:(NSNumber *)page;
@optional
- (void) postFailed:(NSString*)reason page:(NSNumber *)page;
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
- (void) follow:(BOOL)following confirmedForUser:(RYUser *)user;
@optional
- (void) followFailed:(NSString *)reason;
@end

@protocol RiffDelegate <NSObject>
- (void) riffPostSucceeded;
@optional
- (void) riffPostFailed;
@end

@protocol ActionDelegate <NSObject>
- (void) upvoteSucceeded:(RYPost*)updatedPost;
- (void) starSucceeded:(RYPost *)updatedPost;
@optional
- (void) upvoteFailed:(NSString*)reason post:(RYPost *)oldPost;
- (void) starFailed:(NSString *)reason post:(RYPost *)oldPost;
@end

@class RYUser;
@class RYPost;

@interface RYServices : NSObject

+ (RYServices *)sharedInstance;

// Users
- (void) getUserWithId:(NSNumber *)userID orUsername:(NSString *)username delegate:(id<UsersDelegate>)delegate;
- (void) getFollowersForUser:(NSInteger)userID page:(NSNumber *)page delegate:(id<UsersDelegate>)delegate;
- (void) follow:(BOOL)shouldFollow user:(NSInteger)userId forDelegate:(id<FollowDelegate>)delegate;

// User Posts
- (void) postRiffWithContent:(NSString*)content title:(NSString *)title duration:(NSNumber *)duration parentIDs:(NSArray *)parentIDs image:(UIImage *)image ForDelegate:(id<RiffDelegate>)riffDelegate;
- (void) deletePost:(RYPost*)post;

// Other Posts
- (void) getUserPostsForUser:(NSInteger)userId page:(NSNumber *)page delegate:(id<PostDelegate>)delegate;
- (void) getNewsfeedPostsWithPage:(NSNumber *)page delegate:(id<PostDelegate>)delegate;
- (void) getPostsForTags:(NSArray *)tags searchType:(SearchType)searchType page:(NSNumber *)page limit:(NSNumber *)limit delegate:(id<PostDelegate>)delegate;
- (void) getStarredPostsForUser:(NSInteger)userID delegate:(id<PostDelegate>)delegate;
- (void) getFamilyForPost:(NSInteger)postID delegate:(id<FamilyPostDelegate>)delegate;

// Actions
- (void) upvote:(BOOL)shouldUpvote post:(RYPost *)post forDelegate:(id<ActionDelegate>)delegate;
- (void) star:(BOOL)shouldStar post:(RYPost *)post forDelegate:(id<ActionDelegate>)delegate;

// Helper
- (void) getPostsWithParams:(NSDictionary *)params toAction:(NSString *)action page:(NSNumber *)page forDelegate:(id<PostDelegate>)delegate;

@end
