//
//  RYUserListViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 8/22/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYCoreViewController.h"

@class RYUser;

@interface RYUserListViewController : RYCoreViewController

- (void) configureForUsers:(NSArray *)users title:(NSString *)title;
- (void) configureWithFollowersForUser:(RYUser *)user;

@end
