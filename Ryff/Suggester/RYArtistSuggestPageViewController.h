//
//  RYArtistSuggestViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYCorePageViewController.h"

@interface RYArtistSuggestPageViewController : RYCorePageViewController

@property (nonatomic, strong) NSArray *artists;

- (void) goToNextPage;

@end
