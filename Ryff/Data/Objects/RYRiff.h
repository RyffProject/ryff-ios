//
//  RYRiff.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RYRiff : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) NSURL *URL;

- (RYRiff*)initWithTitle:(NSString*)title duration:(NSTimeInterval)duration url:(NSURL*)url;

+ (RYRiff*)riffFromDict:(NSDictionary*)riffDict;
+ (RYRiff*)riffWithURL:(NSURL*)url;

@end
