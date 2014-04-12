//
//  RYUser.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RYUser : NSObject

@property (nonatomic, strong) NSString *username;

- (RYUser *)initWithUsername:(NSString *)username;

@end
