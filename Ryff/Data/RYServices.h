//
//  RYServices.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

// NSUserDefaults keys
#define kLoggedInUserKey @"loggedInUser"
#define kCoordLongitude @"lastUpdatedLongitude"
#define kCoordLatitude @"lastUpdatedLatitude"

// Server paths
#define host @"http://ryff.me/api/"
#define kRegistrationAction @"create-user.php"
#define kAddFriendAction @"add-friend.php"
#define kDeleteFriendAction @"delete-friend.php"
#define kPostRiffAction @"add-post.php"
#define kGetPosts @"get-posts.php"
#define kGetPeople @"get-user.php"
#define kGetNearby @"get-users-nearby.php"
#define kGetFriendsPosts @"get-friend-posts.php"

// Web service dictionary keys
#define kUserObjectKey @"user"

@protocol POSTDelegate <NSObject>
- (void) connectionFailed;
- (void) postFailed:(NSString*)reason;
- (void) postSucceeded:(id)response;
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

@class RYUser;
@class RYNewsfeedPost;

@interface RYServices : NSObject


+ (RYServices *)sharedInstance;
+ (RYUser *) loggedInUser;

+ (NSAttributedString *)createAttributedTextWithPost:(RYNewsfeedPost *)post;

// Server stuff

- (void) submitPOST:(NSString *)actionDestination withDict:(NSDictionary*)jsonDict forDelegate:(id<POSTDelegate>)delegate;
- (void) registerUserWithPOSTDict:(NSDictionary*)params avatar:(UIImage*)image forDelegate:(id<POSTDelegate>)delegate;

// Artist Suggester
@property (nonatomic, weak) id <ArtistsFetchDelegate> artistsDelegate;
- (void) moreArtistsOfCount:(NSInteger)numArtists;
- (void) addFriend:(NSInteger)userId forDelegate:(id<FriendsDelegate>)delegate;
- (void) deleteFriend:(NSInteger)userId forDelegate:(id<FriendsDelegate>)delegate;

// Posts
+ (NSURL*)pathForRiff;
- (void) postRiffWithContent:(NSString*)content title:(NSString*)title duration:(NSNumber*)duration ForDelegate:(id<RiffDelegate>)riffDelegate;
- (void) getMyPostsForDelegate:(id<POSTDelegate>)delegate;
- (void) getFriendPostsForDelegate:(id<POSTDelegate>)delegate;

@end
