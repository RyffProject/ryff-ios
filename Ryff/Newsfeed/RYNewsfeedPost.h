//
//  RYNewsfeedPost.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RYRiff;
@class RYUser;

@interface RYNewsfeedPost : NSObject

@property (nonatomic, assign) NSInteger postId;
@property (nonatomic, strong) RYUser *user;
@property (nonatomic, strong) RYRiff *riff;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, assign) BOOL isStarred;
@property (nonatomic, assign) BOOL isUpvoted;
@property (nonatomic, assign) NSInteger upvotes;

// Optional
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSURL *imageURL;

- (RYNewsfeedPost *)initWithPostId:(NSInteger)postId User:(RYUser *)user Content:(NSString*)content riff:(RYRiff*)riff dateCreated:(NSDate*)dateCreated isUpvoted:(BOOL)isUpvoted isStarred:(BOOL)isStarred upvotes:(NSInteger)upvotes;

+ (RYNewsfeedPost *)newsfeedPostWithDict:(NSDictionary*)postDict;
+ (NSArray *)newsfeedPostsFromDictArray:(NSArray *)dictArray;

@end
