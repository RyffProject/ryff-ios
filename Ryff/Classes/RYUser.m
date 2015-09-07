//
//  RYUser.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYUser.h"

// Data Objects
#import "RYPost.h"
#import "RYTag.h"

// Data Managers
#import "RYServices.h"

// Categories
#import "NSDictionary+Safety.h"
#import "NSMutableDictionary+Safety.h"

// Update Notification Keys
static NSString *UserUpdatedNotificationKey = @"UserUpdatedNotificationKey";
static NSString *UserNotificationKeyUserID = @"userId";
static NSString *UserNotificationKeyUserData = @"user";

// Dictionary Representation Keys
static NSString *UserDictionaryKeyID = @"id";
static NSString *UserDictionaryKeyUsername = @"username";
static NSString *UserDictionaryKeyName = @"name";
static NSString *UserDictionaryKeyKarma = @"karma";
static NSString *UserDictionaryKeyBio = @"bio";
static NSString *UserDictionaryKeyDateCreated = @"date_created";
static NSString *UserDictionaryKeyIsFollowing = @"is_following";
static NSString *UserDictionaryKeyNumFollowers = @"num_followers";
static NSString *UserDictionaryKeyNumFollowing = @"num_following";
static NSString *UserDictionaryKeyTags = @"tags";
static NSString *UserDictionaryKeyAvatarURL = @"avatar_url";
static NSString *UserDictionaryKeyAvatarSmallURL = @"avatar_url_small";

@interface RYUser () <FollowDelegate>

@end

@implementation RYUser

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUpdatedNotification:) name:UserUpdatedNotificationKey object:nil];
    }
    return self;
}

- (RYUser *)initWithUser:(NSInteger)userId username:(NSString *)username nickname:(NSString *)nickname karma:(NSInteger)karma bio:(NSString*)bio dateCreated:(NSDate *)dateCreated isFollowing:(BOOL)isFollowing numFollowers:(NSInteger)numFollowers numFollowing:(NSInteger)numFollowing tags:(NSArray *)tags
{
    if (self = [self init])
    {
        _userId         = userId;
        _username       = username;
        _nickname       = nickname;
        _karma          = karma;
        _bio            = bio;
        _isFollowing    = isFollowing;
        _numFollowers   = numFollowers;
        _numFollowing   = numFollowing;
        _tags           = tags;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (RYUser *)userFromDict:(NSDictionary*)userDict
{
    NSNumber *userId        = [userDict safeObjectForKey:UserDictionaryKeyID];
    NSString *username      = [userDict safeObjectForKey:UserDictionaryKeyUsername];
    NSString *name          = [userDict safeObjectForKey:UserDictionaryKeyName];
    NSNumber *karma         = [userDict safeObjectForKey:UserDictionaryKeyKarma];
    NSString *bio           = [userDict safeObjectForKey:UserDictionaryKeyBio];
    NSString *dateCreated   = [userDict safeObjectForKey:UserDictionaryKeyDateCreated];
    BOOL isFollowing        = [[userDict safeObjectForKey:UserDictionaryKeyIsFollowing] boolValue];
    NSInteger numFollowers  = [[userDict safeObjectForKey:UserDictionaryKeyNumFollowers] intValue];
    NSInteger numFollowing  = [[userDict safeObjectForKey:UserDictionaryKeyNumFollowing] intValue];
    NSArray *tags           = [RYTag tagsFromDictArray:[userDict safeObjectForKey:UserDictionaryKeyTags]];
    
    NSDate *date;
    if (dateCreated)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        date = [dateFormatter dateFromString:dateCreated];
    }
    
    RYUser *newUser = [[RYUser alloc] initWithUser:userId.intValue username:username nickname:name karma:karma.intValue bio:bio dateCreated:date isFollowing:isFollowing numFollowers:numFollowers numFollowing:numFollowing tags:tags];
    
    if (userDict[@"avatar_url"] && [userDict[@"avatar_url"] length] > 0)
        newUser.avatarURL = [NSURL URLWithString:userDict[@"avatar_url"]];
    if (userDict[@"avatar_small_url"] && [userDict[@"avatar_small_url"] length] > 0)
        newUser.avatarSmallURL = [NSURL URLWithString:userDict[@"avatar_small_url"]];
    
    
    return newUser;
}

+ (NSArray *) usersFromDictArray:(NSArray *)dictArray
{
    NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:dictArray.count];
    for (NSDictionary *userDict in dictArray)
    {
        RYUser *newUser = [RYUser userFromDict:userDict];
        [users addObject:newUser];
    }
    return users;
}

+ (RYUser *)sampleUser {
    return [[RYUser alloc] initWithUser:1 username:@"dabeat" nickname:@"Pat" karma:3 bio:@"here's some stuff about me" dateCreated:[NSDate date] isFollowing:NO numFollowers:4 numFollowing:2 tags:@[]];
}

#pragma mark - Actions

- (void)toggleFollowing {
    [[RYServices sharedInstance] follow:!self.isFollowing user:self.userId forDelegate:self];
}

#pragma mark - FollowDelegate

- (void)follow:(BOOL)following confirmedForUser:(RYUser *)user {
    [self.delegate userUpdated:user];
    
    NSDictionary *userInfo = @{UserNotificationKeyUserID: @(user.userId), UserNotificationKeyUserData: [user dictionaryRepresentation]};
    [[NSNotificationCenter defaultCenter] postNotificationName:UserUpdatedNotificationKey object:nil userInfo:userInfo];
}

- (void)followFailed:(NSString *)reason {
    NSLog(@"Follow user %ld failed: %@", self.userId, reason);
    [self.delegate userUpdateFailed:self reason:reason];
}

#pragma mark - Notifications

- (void)userUpdatedNotification:(NSNotification *)notification {
    NSNumber *userID = [notification.userInfo safeObjectForKey:UserNotificationKeyUserID];
    if (userID && userID.integerValue == self.userId) {
        // Data updated, should copy changes.
        NSDictionary *otherDict = [notification.userInfo safeObjectForKey:UserNotificationKeyUserData];
        if (otherDict) {
            [self copyFromDictionary:otherDict];
            [self.delegate userUpdated:self];
        }
    }
}

#pragma mark - Copying

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:16];
    [dictionary safelySetObject:@(self.userId) forKey:UserDictionaryKeyID];
    [dictionary safelySetObject:self.username forKey:UserDictionaryKeyUsername];
    [dictionary safelySetObject:self.nickname forKey:UserDictionaryKeyName];
    [dictionary safelySetObject:self.bio forKey:UserDictionaryKeyBio];
    [dictionary safelySetObject:self.dateCreated forKey:UserDictionaryKeyBio];
    [dictionary safelySetObject:@(self.isFollowing) forKey:UserDictionaryKeyIsFollowing];
    [dictionary safelySetObject:@(self.numFollowers) forKey:UserDictionaryKeyNumFollowers];
    [dictionary safelySetObject:@(self.numFollowing) forKey:UserDictionaryKeyNumFollowing];
    [dictionary safelySetObject:self.avatarURL forKey:UserDictionaryKeyAvatarURL];
    [dictionary safelySetObject:self.avatarSmallURL forKey:UserDictionaryKeyAvatarSmallURL];
    [dictionary safelySetObject:[RYTag dictionaryRepresentationForTags:self.tags] forKey:UserDictionaryKeyTags];
    return dictionary;
}

- (void)copyFromDictionary:(NSDictionary *)dictionaryRepresentation {
    self.userId = [[dictionaryRepresentation safeObjectForKey:UserDictionaryKeyID] integerValue];
    self.username = [dictionaryRepresentation safeObjectForKey:UserDictionaryKeyUsername];
    self.nickname = [dictionaryRepresentation safeObjectForKey:UserDictionaryKeyName];
    self.karma = [[dictionaryRepresentation safeObjectForKey:UserDictionaryKeyKarma] integerValue];
    self.bio = [dictionaryRepresentation safeObjectForKey:UserDictionaryKeyBio];
    self.dateCreated = [dictionaryRepresentation safeObjectForKey:UserDictionaryKeyDateCreated];
    self.isFollowing = [[dictionaryRepresentation safeObjectForKey:UserDictionaryKeyIsFollowing] boolValue];
    self.numFollowers = [[dictionaryRepresentation safeObjectForKey:UserDictionaryKeyNumFollowers] integerValue];
    self.numFollowing = [[dictionaryRepresentation safeObjectForKey:UserDictionaryKeyNumFollowing] integerValue];
    self.avatarURL = [dictionaryRepresentation safeObjectForKey:UserDictionaryKeyAvatarURL];
    self.avatarSmallURL = [dictionaryRepresentation safeObjectForKey:UserDictionaryKeyAvatarSmallURL];
    self.tags = [RYTag tagsFromDictArray:[dictionaryRepresentation safeObjectForKey:UserDictionaryKeyTags]];
}

#pragma mark - NSCopying

-(id)copyWithZone:(NSZone *)zone {
    RYUser *other = [[RYUser alloc] init];
    NSDictionary *dictionaryRepresentation = [self dictionaryRepresentation];
    [other copyFromDictionary:dictionaryRepresentation];
    return other;
}

#pragma mark - NSObject

- (BOOL) isEqual:(id)object {
    BOOL equal = NO;
    if ([object isKindOfClass:[RYUser class]])
    {
        RYUser *other = (RYUser *)object;
        if (other.userId == self.userId)
            equal = YES;
    }
    return equal;
}

- (NSUInteger)hash {
    return self.userId;
}

@end
