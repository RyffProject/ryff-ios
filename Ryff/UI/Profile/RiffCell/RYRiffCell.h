//
//  RYRiffCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRiffCellWidthMinusText isIpad ? 289 : 85.0f
#define kRiffCellHeightMinusText 150.0f
#define kRiffCellMinimumHeight 150.0f
#define kPostImageViewWidth (3/7)*self.contentView.size.width

@protocol RiffCellDelegate <NSObject>
- (void) playerControlAction:(NSInteger)riffIndex;
- (void) upvoteAction:(NSInteger)riffIndex;
- (void) repostAction:(NSInteger)riffIndex;
@end

@class RYNewsfeedPost;

@interface RYRiffCell : UITableViewCell

@property (nonatomic, weak) id<RiffCellDelegate> delegate;

@property (nonatomic, assign) NSInteger riffIndex;

- (void) configureForPost:(RYNewsfeedPost *)post attributedText:(NSAttributedString *)attributedText riffIndex:(NSInteger)riffIndex delegate:(id<RiffCellDelegate>)delegate;

- (void) startDownloading;
- (void) updateDownloadIndicatorWithBytes:(CGFloat)bytesFinished outOf:(CGFloat)totalBytes;
- (void) finishDownloading:(BOOL)success;
- (void) shouldPause:(BOOL)shouldPause;
- (void) updateTimeRemaining:(CGFloat)playProgress;
- (void) clearAudio;

@end
