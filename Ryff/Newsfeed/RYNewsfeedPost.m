//
//  RYNewsfeedPost.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNewsfeedPost.h"

// Data Objects
#import "RYRiff.h"
#import "RYUser.h"

@implementation RYNewsfeedPost

- (RYNewsfeedPost *)initWithPostId:(NSInteger)postId User:(RYUser *)user Content:(NSString*)content riff:(RYRiff*)riff dateCreated:(NSDate*)dateCreated isUpvoted:(BOOL)isUpvoted isStarred:(BOOL)isStarred upvotes:(NSInteger)upvotes
{
    if (self = [super init])
    {
        _postId      = postId;
        _user        = user;
        _content     = content;
        _riff        = riff;
        _dateCreated = dateCreated;
        _isUpvoted   = isUpvoted;
        _upvotes     = upvotes;
        _isStarred   = isStarred;
    }
    return self;
}

+ (RYNewsfeedPost *)newsfeedPostWithDict:(NSDictionary*)postDict
{
    NSNumber *postId = [postDict objectForKey:@"id"];
    
    NSDictionary *userDict = [postDict objectForKey:@"user"];
    RYUser *user = [RYUser userFromDict:userDict];
    
    NSString *content = [postDict objectForKey:@"content"];
    
    RYRiff *riff;
    id riffResponse = [postDict objectForKey:@"riff"];
    if ([riffResponse isKindOfClass:[NSDictionary class]])
    {
        riff = [RYRiff riffFromDict:riffResponse];
    }
    
    NSString *date_created = [userDict objectForKey:@"date_created"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-DD HH:MM:SS"];
    NSDate *date = [dateFormatter dateFromString:date_created];
    
    BOOL isUpvoted = [postDict[@"is_upvoted"] boolValue];
    NSInteger upvotes = [postDict[@"upvotes"] intValue];
    
    BOOL isStarred = [postDict[@"is_starred"] boolValue];
    
    RYNewsfeedPost *newPost = [[RYNewsfeedPost alloc] initWithPostId:[postId integerValue] User:user Content:content riff:riff dateCreated:date isUpvoted:isUpvoted isStarred:isStarred upvotes:upvotes];
    
    if (postDict[@"image_url"] && ((NSString*)postDict[@"image_url"]).length > 0)
        newPost.imageURL = [NSURL URLWithString:postDict[@"image_url"]];
    
    return newPost;
}

+ (NSArray *)newsfeedPostsFromDictArray:(NSArray *)dictArray
{
    NSMutableArray *posts = [[NSMutableArray alloc] init];
    
    for (NSDictionary *postDict in dictArray)
    {
        RYNewsfeedPost *post = [RYNewsfeedPost newsfeedPostWithDict:postDict];
        [posts addObject:post];
    }
    
    return posts;
}

@end
