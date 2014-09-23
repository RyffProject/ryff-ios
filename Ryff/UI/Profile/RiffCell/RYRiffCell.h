//
//  RYRiffCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRiffCellWidthMinusText isIpad ? 390.0f : 85.0f
#define kRiffCellWidthMinusTextAvatar isIpad ? 255.0f : 85.0f
#define kRiffCellWidthMinusTextNoImage isIpad ? 192.0f : 85.0f
#define kRiffCellHeightMinusText 170.0f
#define kRiffCellMinimumHeight 259.0f

// Details
#define kRiffDetailsHeightMinusText 494.0f

@protocol RiffCellDelegate <NSObject>
- (void) playerControlAction:(NSInteger)riffIndex;
- (void) avatarAction:(NSInteger)riffIndex;
- (void) upvoteAction:(NSInteger)riffIndex;
- (void) repostAction:(NSInteger)riffIndex;
- (void) starAction:(NSInteger)riffIndex;
@end

@class RYPost;
@class RYSocialTextView;

@interface RYRiffCell : UITableViewCell

@property (nonatomic, weak) id<RiffCellDelegate> delegate;

@property (nonatomic, assign) NSInteger riffIndex;

@property (weak, nonatomic) IBOutlet RYSocialTextView *socialTextView;

- (void) configureForPost:(RYPost *)post riffIndex:(NSInteger)riffIndex delegate:(id<RiffCellDelegate>)delegate;

@end
