//
//  RYProfileInfoTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/23/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileInfoCellDelegate <NSObject>
- (void) settingsAction:(CGRect)presentingFrame;
- (void) addNewRiff;
- (void) editImageAction;
@end

@class RYUser;

@interface RYProfileInfoTableViewCell : UITableViewCell

- (void) configureForUser:(RYUser *)user delegate:(id<ProfileInfoCellDelegate>)delegate parentTableView:(UITableView *)tableView;

@end
