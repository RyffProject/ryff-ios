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
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *avatarURL;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, assign) NSInteger karma;

@property (nonatomic, strong) NSSet *genres;
@property (nonatomic, strong) NSSet *instruments;
@property (nonatomic, strong) NSArray *activity; // NSArray of NewsfeedPost objects

- (RYUser *)initWithUser:(NSInteger)userId username:(NSString *)username nickname:(NSString *)nickname avatarURL:(NSString*)avatarURL karma:(NSInteger)karma bio:(NSString*)bio dateCreated:(NSDate *)dateCreated genres:(NSSet*)genres instruments:(NSSet*)instruments;

+ (RYUser *)userFromDict:(NSDictionary*)userDict;

@end
