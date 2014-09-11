//
//  RYPost.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RYUser;

@interface RYPost : NSObject

@property (nonatomic, assign) NSInteger postId;
@property (nonatomic, strong) RYUser *user;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *riffURL;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, assign) BOOL isStarred;
@property (nonatomic, assign) BOOL isUpvoted;
@property (nonatomic, assign) NSInteger upvotes;

// Optional
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSArray *tags;

- (RYPost *)initWithPostId:(NSInteger)postId User:(RYUser *)user Content:(NSString*)content title:(NSString *)title riffURL:(NSURL*)riffURL duration:(CGFloat)duration dateCreated:(NSDate*)dateCreated isUpvoted:(BOOL)isUpvoted isStarred:(BOOL)isStarred upvotes:(NSInteger)upvotes;

+ (RYPost *)postWithDict:(NSDictionary*)postDict;
+ (NSArray *)postsFromDictArray:(NSArray *)dictArray;

@end
