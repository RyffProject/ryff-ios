//
//  RYRiffStreamingCoreViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYCoreViewController.h"

// Custom UI
#import "RYRiffCell.h"
#import "RYStyleSheet.h"

// Data Managers
#import "RYServices.h"
#import "RYAudioDeckManager.h"

// Data Objects
#import "RYNewsfeedPost.h"
#import "RYRiff.h"
#import "RYUser.h"

#define kRiffCellReuseID @"RiffCell"

@interface RYRiffStreamingCoreViewController : RYCoreViewController <UpvoteDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *riffTableView;
@property (nonatomic, strong) NSArray *feedItems;
@property (nonatomic, assign) NSInteger riffSection;

@end
