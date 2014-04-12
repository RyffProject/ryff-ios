//
//  RYServices.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLoggedInUserKey @"loggedInUser"

#define host @"http://ryff.me/api/"

#define kRegistrationAction @"create-user.php"

@protocol POSTDelegate <NSObject>

- (void) connectionFailed;
- (void) postFailed;
- (void) postSucceeded:(id)response;

@end

@class RYUser;
@class RYNewsfeedPost;

@interface RYServices : NSObject

+ (RYServices *)sharedInstance;

+ (RYUser *) loggedInUser;

+ (NSAttributedString *)createAttributedTextWithPost:(RYNewsfeedPost *)post;

- (void) submitPOST:(NSString *)actionDestination withDict:(NSDictionary*)jsonDict forDelegate:(id<POSTDelegate>)delegate;
- (void) submitAuthenticatedRest_POST:(NSString *)actionDestination withDict:(NSDictionary*)jsonDict forDelegate:(id<POSTDelegate>)delegate;

@end
