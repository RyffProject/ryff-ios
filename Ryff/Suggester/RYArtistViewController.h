//
//  RYArtistViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYCoreViewController.h"

@class RYUser;

@interface RYArtistViewController : RYCoreViewController

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UITextView *bioText;
@property (weak, nonatomic) IBOutlet UITableView *riffTableView;

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) BOOL friends;

@property (nonatomic, strong) RYUser *artist;

- (void) friendStatus:(BOOL)friends;
- (void) configureForArtist;

@end