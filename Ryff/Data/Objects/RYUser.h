//
//  RYUser.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RYUser : NSObject

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, assign) NSInteger karma;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, assign) NSInteger numFollowers;
@property (nonatomic, assign) NSInteger numFollowing;

// Optional
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSURL *avatarURL;
@property (nonatomic, strong) NSString *nickname;

- (RYUser *)initWithUser:(NSInteger)userId username:(NSString *)username nickname:(NSString *)nickname avatarURL:(NSURL*)avatarURL karma:(NSInteger)karma bio:(NSString*)bio dateCreated:(NSDate *)dateCreated isFollowing:(BOOL)isFollowing numFollowers:(NSInteger)numFollowers numFollowing:(NSInteger)numFollowing tags:(NSArray *)tags;
+ (RYUser *)userFromDict:(NSDictionary*)userDict;

@end
