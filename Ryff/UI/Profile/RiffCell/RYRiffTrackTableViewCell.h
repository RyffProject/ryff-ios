//
//  RYRiffTrackTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRiffTitleCellPadding 20.0f

@class RYRiff;
@class RMDownloadIndicator;
@class RYNewsfeedPost;

enum LoadingStatus : NSUInteger {
    STOP = 1,
    PLAY = 2,
    PAUSE = 3,
    DOWNLOAD = 4
};

@interface RYRiffTrackTableViewCell : UITableViewCell

// Duration objects
@property (nonatomic, assign) NSInteger riffDuration;

- (void) configureForPost:(RYNewsfeedPost *)post;
- (void) startDownloading;
- (void) updateDownloadIndicatorWithBytes:(CGFloat)bytesFinished outOf:(CGFloat)totalBytes;
- (void) finishDownloading:(BOOL)success;
- (void) shouldPause:(BOOL)shouldPause;
- (void) updateTimeRemaining:(NSInteger)secondsRemaining;
- (void) clearAudio;

@end
