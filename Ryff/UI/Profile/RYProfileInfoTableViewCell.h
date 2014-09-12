//
//  RYProfileInfoTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/23/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RYServices.h"
#import "RYRegistrationServices.h"

#define kProfileInfoCellWidthMinusText isIpad ? 171.0f : 258.0f
#define kProfileInfoCellHeightMinusText 412.0f
#define kProfileInfoCellMinimumHeight 412.0f
#define kProfileInfoCellFont [UIFont fontWithName:kRegularFont size:18.0f]

@class RYUser;

@protocol ProfileInfoCellDelegate <NSObject>
- (void) settingsAction:(CGRect)presentingFrame;
- (void) followAction;
- (void) messageAction;
- (void) editImageAction;
- (void) followersAction;
- (void) tagSelected:(NSInteger)tagSelected;
@end

@interface RYProfileInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *bioTextView;

- (void) configureForUser:(RYUser *)user delegate:(id<ProfileInfoCellDelegate, UpdateUserDelegate>)delegate parentTableView:(UITableView *)tableView;
- (void) enableUserSettingOptions;

@end
