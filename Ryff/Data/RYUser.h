//
//  RYUser.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RYUser : NSObject

@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSSet *groups;
@property (nonatomic, strong) NSArray *activity; // NSArray of NewsfeedPost objects

- (RYUser *)initWithUsername:(NSString *)username firstName:(NSString *)firstName profileImage:(UIImage *)profileImage bio:(NSString*)bio groups:(NSSet*)groups activity:(NSArray *)activity;

+ (RYUser *)patrick;

@end
