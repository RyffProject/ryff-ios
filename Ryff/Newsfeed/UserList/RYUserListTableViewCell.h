//
//  RYUserListTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 8/22/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYUser;

@interface RYUserListTableViewCell : UITableViewCell

- (void) configureForUser:(RYUser *)user;

@end
