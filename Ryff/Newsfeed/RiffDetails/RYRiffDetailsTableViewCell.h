//
//  RYRiffDetailsTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/30/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRiffDetailsCellHeightMinusText 120.0f
#define kRiffDetailsCellMinimumHeight 150.0f
#define kRiffDetailsWidthMinusText isIpad ? 85.0f : 85.0f

@protocol RiffDetailsDelegate <NSObject>
- (void) upvoteAction;
- (void) repostAction;
- (void) followAction;
- (void) progressSliderChanged:(CGFloat)newProgress;
- (void) avatarTapAction;
- (void) playControlAction;
@end

@class RYNewsfeedPost;

@interface RYRiffDetailsTableViewCell : UITableViewCell

- (void) configureWithPost:(RYNewsfeedPost *)post delegate:(id<RiffDetailsDelegate>)delegate;

@end
