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

@property (nonatomic, strong) RYUser *user;
@property (nonatomic, strong) NSString *mainText;
@property (nonatomic, strong) RYRiff *riff;

- (RYNewsfeedPost *)initWithUser:(RYUser *)user mainText:(NSString*)mainText riff:(RYRiff*)riff;

@end
