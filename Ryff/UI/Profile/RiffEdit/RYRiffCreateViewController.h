//
//  RYRiffCreateViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 6/17/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RYDataManager.h"

@interface RYRiffCreateViewController : UIViewController <TrackDownloadDelegate>

- (void) includeRiffs:(NSArray*)arrayOfRiffs;

@end
