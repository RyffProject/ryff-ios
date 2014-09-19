//
//  RYUserListCollectionViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/19/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYUser;

@interface RYUserListCollectionViewCell : UICollectionViewCell

- (void) configureWithUser:(RYUser *)user;

+ (CGSize) preferredSizeWithAvailableSize:(CGSize)boundingSize forUser:(RYUser *)user;

@end
