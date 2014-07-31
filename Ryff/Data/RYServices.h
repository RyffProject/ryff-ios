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
#define kApiRoot            @"http://ryff.me/api/"
#define kLogIn              @"login.php"
#define kRegistrationAction @"create-user.php"
#define kUpdateUserAction   @"update-user.php"
#define kAddFriendAction    @"add-friend.php"
#define kDeleteFriendAction @"delete-friend.php"
#define kPostRiffAction     @"add-post.php"
#define kUpvotePostAction   @"add-upvote.php"
#define kDeleteUpvoteAction @"delete-upvote.php"
#define kDeletePostAction   @"delete-post.php"
#define kGetPostFamily      @"get-post-family.php"
#define kGetPosts           @"get-posts.php"
#define kGetPeople          @"get-user.php"
#define kGetNearby          @"get-users-nearby.php"
#define kGetFriendsPosts    @"get-friend-posts.php"

@class RYNewsfeedPost;
@class RYUser;

@protocol PostDelegate <NSObject>
- (void) postFailed:(NSString*)reason;
- (void) postSucceeded:(NSArray*)posts;
@end

@protocol ArtistsFetchDelegate <NSObject>
- (void) retrievedArtists:(NSArray*)artists;
@end

@protocol FriendsDelegate <NSObject>
- (void) friendConfirmed;
- (void) friendDeleted;
- (void) actionFailed;
@end

@protocol RiffDelegate <NSObject>
- (void) riffPostSucceeded;
- (void) riffPostFailed;
@end

@protocol UpvoteDelegate <NSObject>
- (void) upvoteSucceeded:(RYNewsfeedPost*)updatedPost;
- (void) upvoteFailed:(NSString*)reason;
@end

@protocol UpdateUserDelegate <NSObject>
- (void) updateSucceeded:(NSDictionary*)userDict;
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
- (void) editUserInfo:(RYUser*)user;
- (void) deletePost:(RYNewsfeedPost*)post;

// Discover
@property (nonatomic, weak) id <ArtistsFetchDelegate> artistsDelegate;
- (void) moreArtistsOfCount:(NSInteger)numArtists;
- (void) addFriend:(NSInteger)userId forDelegate:(id<FriendsDelegate>)delegate;
- (void) deleteFriend:(NSInteger)userId forDelegate:(id<FriendsDelegate>)delegate;

// Posts
+ (NSURL*)urlForRiff;
- (void) postRiffWithContent:(NSString*)content title:(NSString*)title duration:(NSNumber*)duration ForDelegate:(id<RiffDelegate>)riffDelegate;
- (void) getUserPostsForUser:(NSInteger)userId Delegate:(id<PostDelegate>)delegate;
- (void) getFriendPostsForDelegate:(id<PostDelegate>)delegate;
- (void) upvote:(BOOL)shouldUpvote post:(NSInteger)postID forDelegate:(id<UpvoteDelegate>)delegate;
- (void) getFamilyForPost:(NSInteger)postID delegate:(id<PostDelegate>)delegate;

@end
