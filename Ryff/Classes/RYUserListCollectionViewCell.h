//
//  RYUserListCollectionViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/19/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYUser;

@protocol UserListCellDelegate <NSObject>
- (void)followUserTapped:(RYUser *)user;
- (void)tagSelected:(NSString *)tag;
@end

@interface RYUserListCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<UserListCellDelegate> delegate;

- (void) configureWithUser:(RYUser *)user delegate:(id<UserListCellDelegate>)delegate;

+ (CGSize) preferredSizeWithAvailableSize:(CGSize)boundingSize forUser:(RYUser *)user;

@end
