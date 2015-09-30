//
//  RYProfileViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYRiffStreamingCoreViewController.h"

@class RYUser;

@interface RYOLDProfileViewController : RYRiffStreamingCoreViewController

- (void) configureForUser:(RYUser *)user;
- (void) configureForUsername:(NSString *)username;
- (void) addSettingsOptions;

@end