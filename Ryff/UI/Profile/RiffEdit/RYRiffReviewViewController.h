//
//  RYRiffReviewViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/13/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYCoreViewController.h"

@class RYRiff;

@interface RYRiffReviewViewController : RYCoreViewController

- (void) configureWithRiff:(RYRiff *)riff;

@end
