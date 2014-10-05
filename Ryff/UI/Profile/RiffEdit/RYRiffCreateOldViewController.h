//
//  RYRiffCreateOldViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 6/17/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RYCoreViewController.h"
#import "RYDataManager.h"

@interface RYRiffCreateOldViewController : RYCoreViewController <TrackDownloadDelegate>

- (void) includeRiffs:(NSArray*)arrayOfRiffs;

@end
