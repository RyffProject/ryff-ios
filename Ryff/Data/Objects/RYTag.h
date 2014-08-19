//
//  RYTag.h
//  Ryff
//
//  Created by Christopher Laganiere on 8/19/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RYTag : NSObject

@property (nonatomic, strong) NSString *tag;
@property (nonatomic, assign) NSInteger numUsers;
@property (nonatomic, assign) NSInteger numPosts;

- (RYTag *)initWithTag:(NSString *)tag numUsers:(NSInteger)numUsers numPosts:(NSInteger)numPosts;
+ (RYTag *)tagFromDict:(NSDictionary *)tagDict;
+ (NSArray *)tagsFromDictArray:(NSArray *)tagDictArray;

+ (NSArray *)getTagTags:(NSArray *)tags;

@end
