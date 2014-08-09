//
//  RYProfileInfoTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/23/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RYServices.h"

#define kProfileInfoCellWidthMinusText isIpad ? 258.0f : 258.0f
#define kProfileInfoCellHeightMinusText 176.0f
#define kProfileInfoCellMinimumHeight 260.0f
#define kProfileInfoCellFont [UIFont fontWithName:kRegularFont size:18.0f]

@class RYUser;

@protocol ProfileInfoCellDelegate <NSObject>
- (void) settingsAction:(CGRect)presentingFrame;
- (void) addNewRiff;
- (void) editImageAction;
- (void) followersAction;
@end

@interface RYProfileInfoTableViewCell : UITableViewCell

- (void) configureForUser:(RYUser *)user delegate:(id<ProfileInfoCellDelegate, UpdateUserDelegate>)delegate parentTableView:(UITableView *)tableView;

@end
