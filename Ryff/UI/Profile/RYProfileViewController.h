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

@interface RYProfileViewController : RYRiffStreamingCoreViewController

@property (nonatomic, strong) RYUser *user;

@end