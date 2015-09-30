//
//  RYPost.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYPost.h"

// Data Managers
#import "RYServices.h"

// Data Objects
#import "RYUser.h"

// Categories
#import "NSDictionary+Safety.h"
#import "NSMutableDictionary+Safety.h"

// Update Notification Keys
static NSString *PostUpdatedNotificationKey = @"PostUpdatedNotificationKey";
static NSString *PostNotificationKeyUserID = @"postId";
static NSString *PostNotificationKeyUserData = @"post";

// Dictionary Representation Keys
static NSString *PostDictionaryKeyID = @"id";
static NSString *PostDictionaryKeyUser = @"user";
static NSString *PostDictionaryKeyContent = @"content";
static NSString *PostDictionaryKeyTitle = @"title";
static NSString *PostDictionaryKeyDuration = @"duration";
static NSString *PostDictionaryKeyRiffURL = @"riff_url";
static NSString *PostDictionaryKeyDateCreated = @"date_created";
static NSString *PostDictionaryKeyIsUpvoted = @"is_upvoted";
static NSString *PostDictionaryKeyUpvotes = @"upvotes";
static NSString *PostDictionaryKeyIsStarred = @"is_starred";
static NSString *PostDictionaryKeyImageURL = @"image_url";
static NSString *PostDictionaryKeyImageMediumURL = @"image_medium_url";
static NSString *PostDictionaryKeyImageSmallURL = @"image_small_url";
static NSString *PostDictionaryKeyRiffHQURL = @"riff_hq_url";
static NSString *PostDictionaryKeyTags = @"tags";

@interface RYPost () <ActionDelegate>

@end

@implementation RYPost

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postUpdatedNotification:) name:PostUpdatedNotificationKey object:nil];
    }
    return self;
}

- (RYPost *)initWithPostId:(NSInteger)postId User:(RYUser *)user Content:(NSString*)content title:(NSString *)title riffURL:(NSURL*)riffURL duration:(CGFloat)duration dateCreated:(NSDate*)dateCreated isUpvoted:(BOOL)isUpvoted isStarred:(BOOL)isStarred upvotes:(NSInteger)upvotes
{
    if (self = [self init])
    {
        _postId      = postId;
        _user        = user;
        _content     = content;
        _title       = title;
        _duration    = duration;
        _riffURL     = riffURL;
        _dateCreated = dateCreated;
        _isUpvoted   = isUpvoted;
        _upvotes     = upvotes;
        _isStarred   = isStarred;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (RYPost *)postWithDict:(NSDictionary*)postDict
{
    NSNumber *postId = [postDict objectForKey:@"id"];
    
    NSDictionary *userDict = [postDict objectForKey:@"user"];
    RYUser *user = [RYUser userFromDict:userDict];
    
    NSString *title   = [postDict objectForKey:@"title"];
    NSString *content = [postDict objectForKey:@"content"];
    
    NSURL *riffURL = [NSURL URLWithString:[postDict objectForKey:@"riff_url"]];
    CGFloat duration = [[postDict objectForKey:@"duration"] floatValue];
    
    NSString *date_created = [userDict objectForKey:@"date_created"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:date_created];
    
    BOOL isUpvoted = [postDict[@"is_upvoted"] boolValue];
    NSInteger upvotes = [postDict[@"upvotes"] intValue];
    
    BOOL isStarred = [postDict[@"is_starred"] boolValue];
    
    RYPost *newPost = [[RYPost alloc] initWithPostId:[postId integerValue] User:user Content:content title:title riffURL:riffURL duration:duration dateCreated:date isUpvoted:isUpvoted isStarred:isStarred upvotes:upvotes];
    
    if (postDict[@"image_url"] && ((NSString*)postDict[@"image_url"]).length > 0)
        newPost.imageURL = [NSURL URLWithString:postDict[@"image_url"]];
    if (postDict[@"image_medium_url"] && [postDict[@"image_medium_url"] length] > 0)
        newPost.imageMediumURL = [NSURL URLWithString:postDict[@"image_medium_url"]];
    if (postDict[@"image_small_url"] && [postDict[@"image_small_url"] length] > 0)
        newPost.imageSmallURL = [NSURL URLWithString:postDict[@"image_small_url"]];
    
    if (postDict[@"riff_hq_url"] && [postDict[@"riff_hq_url"] length] > 0)
        newPost.riffHQURL = [NSURL URLWithString:postDict[@"riff_hq_url"]];
    
    return newPost;
}

+ (NSArray *)postsFromDictArray:(NSArray *)dictArray
{
    NSMutableArray *posts = [[NSMutableArray alloc] init];
    
    for (NSDictionary *postDict in dictArray)
    {
        RYPost *post = [RYPost postWithDict:postDict];
        [posts addObject:post];
    }
    
    return posts;
}

#pragma mark - Actions

- (void)toggleStarred {
    [[RYServices sharedInstance] star:!self.isStarred post:self forDelegate:self];
}

#pragma mark - ActionDelegate

- (void) upvoteSucceeded:(RYPost*)updatedPost {
    [self.delegate postUpdated:updatedPost];
    
    NSDictionary *userInfo = @{PostNotificationKeyUserID: @(updatedPost.postId), PostNotificationKeyUserData: [updatedPost dictionaryRepresentation]};
    [[NSNotificationCenter defaultCenter] postNotificationName:PostUpdatedNotificationKey object:nil userInfo:userInfo];
}

- (void) starSucceeded:(RYPost *)updatedPost {
    [self.delegate postUpdated:updatedPost];
    
    NSDictionary *userInfo = @{PostNotificationKeyUserID: @(updatedPost.postId), PostNotificationKeyUserData: [updatedPost dictionaryRepresentation]};
    [[NSNotificationCenter defaultCenter] postNotificationName:PostUpdatedNotificationKey object:nil userInfo:userInfo];
}

- (void) upvoteFailed:(NSString*)reason post:(RYPost *)oldPost {
    NSLog(@"Upvote post %ld failed: %@", self.postId, reason);
    [self.delegate postUpdateFailed:oldPost reason:reason];
}

- (void) starFailed:(NSString *)reason post:(RYPost *)oldPost {
    NSLog(@"Star post %ld failed: %@", self.postId, reason);
    [self.delegate postUpdateFailed:oldPost reason:reason];
}

#pragma mark - Notifications

- (void)postUpdatedNotification:(NSNotification *)notification {
    NSNumber *postId = [notification.userInfo safeObjectForKey:PostNotificationKeyUserID];
    if (postId && postId.integerValue == self.postId) {
        // Data updated, should copy changes.
        NSDictionary *otherDict = [notification.userInfo safeObjectForKey:PostNotificationKeyUserData];
        if (otherDict) {
            [self copyFromDictionary:otherDict];
            [self.delegate postUpdated:self];
        }
    }
}

#pragma mark - Copying

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:16];
    [dictionary safelySetObject:@(self.postId) forKey:PostDictionaryKeyID];
    [dictionary safelySetObject:self.content forKey:PostDictionaryKeyContent];
    [dictionary safelySetObject:self.title forKey:PostDictionaryKeyTitle];
    [dictionary safelySetObject:self.riffURL forKey:PostDictionaryKeyRiffURL];
    [dictionary safelySetObject:@(self.duration) forKey:PostDictionaryKeyDuration];
    [dictionary safelySetObject:self.dateCreated forKey:PostDictionaryKeyDateCreated];
    [dictionary safelySetObject:@(self.isUpvoted) forKey:PostDictionaryKeyIsUpvoted];
    [dictionary safelySetObject:@(self.isStarred) forKey:PostDictionaryKeyIsStarred];
    [dictionary safelySetObject:@(self.upvotes) forKey:PostDictionaryKeyUpvotes];
    [dictionary safelySetObject:self.riffHQURL forKey:PostDictionaryKeyRiffHQURL];
    [dictionary safelySetObject:self.imageURL forKey:PostDictionaryKeyImageURL];
    [dictionary safelySetObject:self.imageMediumURL forKey:PostDictionaryKeyImageMediumURL];
    [dictionary safelySetObject:self.imageSmallURL forKey:PostDictionaryKeyImageSmallURL];
    [dictionary safelySetObject:[RYTag dictionaryRepresentationForTags:self.tags] forKey:PostDictionaryKeyTags];
    return dictionary;
}

- (void)copyFromDictionary:(NSDictionary *)dictionaryRepresentation {
    self.postId = [[dictionaryRepresentation safeObjectForKey:PostDictionaryKeyID] integerValue];
    self.content = [dictionaryRepresentation safeObjectForKey:PostDictionaryKeyContent];
    self.title = [dictionaryRepresentation safeObjectForKey:PostDictionaryKeyTitle];
    self.riffURL = [dictionaryRepresentation safeObjectForKey:PostDictionaryKeyRiffURL];
    self.duration = [[dictionaryRepresentation safeObjectForKey:PostDictionaryKeyDuration] floatValue];
    self.dateCreated = [dictionaryRepresentation safeObjectForKey:PostDictionaryKeyDateCreated];
    self.isUpvoted = [[dictionaryRepresentation safeObjectForKey:PostDictionaryKeyIsUpvoted] boolValue];
    self.isStarred = [[dictionaryRepresentation safeObjectForKey:PostDictionaryKeyIsStarred] boolValue];
    self.upvotes = [[dictionaryRepresentation safeObjectForKey:PostDictionaryKeyUpvotes] integerValue];
    self.riffHQURL = [dictionaryRepresentation safeObjectForKey:PostDictionaryKeyRiffHQURL];
    self.imageURL = [dictionaryRepresentation safeObjectForKey:PostDictionaryKeyImageURL];
    self.imageMediumURL = [dictionaryRepresentation safeObjectForKey:PostDictionaryKeyImageMediumURL];
    self.imageSmallURL = [dictionaryRepresentation safeObjectForKey:PostDictionaryKeyImageSmallURL];
}

#pragma mark - NSCopying

-(id)copyWithZone:(NSZone *)zone
{
    RYPost *other = [[RYPost alloc] init];
    NSDictionary *dictionaryRepresentation = [self dictionaryRepresentation];
    [other copyFromDictionary:dictionaryRepresentation];
    return other;
}

#pragma mark - NSObject

- (BOOL) isEqual:(id)object
{
    BOOL equal = NO;
    if ([object isKindOfClass:[RYPost class]])
    {
        RYPost *other = (RYPost *)object;
        if (other.postId == self.postId)
            equal = YES;
    }
    return equal;
}

- (NSUInteger)hash
{
    return _postId;
}

@end
