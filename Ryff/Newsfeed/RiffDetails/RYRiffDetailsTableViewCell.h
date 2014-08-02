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
- (void) riffUpvoteAction;
- (void) riffRepostAction;
- (void) riffFollowAction;
- (void) riffProgressSliderChanged:(CGFloat)newProgress;
- (void) riffAvatarTapAction;
- (void) riffPlayControlAction;
@end

@class RYNewsfeedPost;

@interface RYRiffDetailsTableViewCell : UITableViewCell

- (void) configureWithPost:(RYNewsfeedPost *)post delegate:(id<RiffDetailsDelegate>)delegate;
- (void) setPlayProgress:(CGFloat)progress;
- (void) shouldPause:(BOOL)pause;

@end
