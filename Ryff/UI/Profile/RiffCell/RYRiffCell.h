//
//  RYRiffCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRiffCellWidthMinusText isIpad ? 289.0f : 85.0f
#define kRiffCellHeightMinusText 130.0f
#define kRiffCellMinimumHeight 130.0f

@protocol RiffCellDelegate <NSObject>
- (void) playerControlAction:(NSInteger)riffIndex;
- (void) avatarAction:(NSInteger)riffIndex;
- (void) upvoteAction:(NSInteger)riffIndex;
- (void) repostAction:(NSInteger)riffIndex;
- (void) starAction:(NSInteger)riffIndex;
@end

@class RYNewsfeedPost;

@interface RYRiffCell : UITableViewCell

@property (nonatomic, weak) id<RiffCellDelegate> delegate;

@property (nonatomic, assign) NSInteger riffIndex;

- (void) configureForPost:(RYNewsfeedPost *)post attributedText:(NSAttributedString *)attributedText riffIndex:(NSInteger)riffIndex delegate:(id<RiffCellDelegate>)delegate;

@end
