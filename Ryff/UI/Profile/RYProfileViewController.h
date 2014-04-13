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

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UIButton *recentActivityButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) RYUser *user;

- (IBAction)editHit:(id)sender;
- (IBAction)activityHit:(id)sender;
- (IBAction)addHit:(id)sender;
- (IBAction)aboutHit:(id)sender;

@end