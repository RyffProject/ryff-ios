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

@interface RYPost () <ActionDelegate>

@end

@implementation RYPost

- (RYPost *)initWithPostId:(NSInteger)postId User:(RYUser *)user Content:(NSString*)content title:(NSString *)title riffURL:(NSURL*)riffURL duration:(CGFloat)duration dateCreated:(NSDate*)dateCreated isUpvoted:(BOOL)isUpvoted isStarred:(BOOL)isStarred upvotes:(NSInteger)upvotes
{
    if (self = [super init])
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
}

- (void) starSucceeded:(RYPost *)updatedPost {
    [self.delegate postUpdated:updatedPost];
}

- (void) upvoteFailed:(NSString*)reason post:(RYPost *)oldPost {
    NSLog(@"Upvote post %ld failed: %@", self.postId, reason);
    [self.delegate postUpdateFailed:oldPost reason:reason];
}

- (void) starFailed:(NSString *)reason post:(RYPost *)oldPost {
    NSLog(@"Star post %ld failed: %@", self.postId, reason);
    [self.delegate postUpdateFailed:oldPost reason:reason];
}

#pragma mark - NSCopying

-(id)copyWithZone:(NSZone *)zone
{
    RYPost *newPost = [[RYPost alloc] initWithPostId:self.postId User:[self.user copy] Content:self.content title:self.title riffURL:self.riffURL duration:self.duration dateCreated:self.dateCreated isUpvoted:self.isUpvoted isStarred:self.isStarred upvotes:self.upvotes];
    newPost.riffHQURL = self.riffHQURL;
    newPost.imageURL = self.imageURL;
    newPost.imageMediumURL = self.imageMediumURL;
    newPost.imageSmallURL = self.imageSmallURL;
    newPost.tags = self.tags;
    return newPost;
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
