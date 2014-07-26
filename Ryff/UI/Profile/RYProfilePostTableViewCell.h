//
//  RYProfileTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kProfilePostCellLabelRatio isIpad ? (683.0f/768.0f) : (683.0f/768.0f)
#define kProfilePostCellHeightMinusText 52.0f
#define kProfilePostCellMinimumHeight 80.0f

@protocol ProfilePostCellDelegate <NSObject>
- (void) playerControlAction:(NSInteger)riffIndex;
- (void) upvoteAction:(NSInteger)riffIndex;
- (void) repostAction:(NSInteger)riffIndex;
- (void) followAction:(NSInteger)riffIndex;
@end

@class RYNewsfeedPost;

@interface RYProfilePostTableViewCell : UITableViewCell

@property (nonatomic, weak) id<ProfilePostCellDelegate> delegate;

@property (nonatomic, assign) NSInteger riffIndex;

- (void) configureForPost:(RYNewsfeedPost *)post attributedText:(NSAttributedString *)attributedText riffIndex:(NSInteger)riffIndex delegate:(id<ProfilePostCellDelegate>)delegate;

@end
