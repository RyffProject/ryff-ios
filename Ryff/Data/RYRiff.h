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
@property (nonatomic, assign) NSTimeInterval length;
@property (nonatomic, strong) NSString *URL;

- (RYRiff*)initWithTitle:(NSString*)title length:(NSTimeInterval)length url:(NSString*)url;

@end
