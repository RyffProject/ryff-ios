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

@class RYUser;
@class RYNewsfeedPost;

@interface RYServices : NSObject


+ (RYServices *)sharedInstance;
+ (RYUser *) loggedInUser;

+ (NSAttributedString *)createAttributedTextWithPost:(RYNewsfeedPost *)post;

// Server stuff

- (void) submitPOST:(NSString *)actionDestination withDict:(NSDictionary*)jsonDict forDelegate:(id<POSTDelegate>)delegate;
- (void) registerUserWithPOSTDict:(NSDictionary*)params avatar:(UIImage*)image forDelegate:(id<POSTDelegate>)delegate;
- (void) submitAuthenticatedRest_POST:(NSString *)actionDestination withDict:(NSDictionary*)jsonDict forDelegate:(id<POSTDelegate>)delegate;

// Artist Suggester
@property (nonatomic, weak) id <ArtistsFetchDelegate> artistsDelegate;
- (void) moreArtistsOfCount:(NSInteger)numArtists;
- (void) addFriend:(NSInteger)userId;

@end
