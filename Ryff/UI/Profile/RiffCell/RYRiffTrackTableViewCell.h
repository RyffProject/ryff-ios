//
//  RYRiffTrackTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYRiff;
@class RMDownloadIndicator;

enum LoadingStatus : NSUInteger {
    STOP = 1,
    PLAY = 2,
    PAUSE = 3,
    DOWNLOAD = 4
};

@interface RYRiffTrackTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *riffTitleText;
@property (weak, nonatomic) IBOutlet UILabel *riffLengthText;

@property (nonatomic, strong) RMDownloadIndicator *downloadIndicator;

// Duration objects
@property (nonatomic, assign) NSInteger riffDuration;

- (void) configureForRiff:(RYRiff *)riff;
- (void) startDownloading;
- (void) updateDownloadIndicatorWithBytes:(CGFloat)bytesFinished outOf:(CGFloat)totalBytes;
- (void) finishDownloading:(BOOL)success;
- (void) shouldPause:(BOOL)shouldPause;
- (void) updateTimeRemaining:(NSInteger)secondsRemaining;
- (void) clearAudio;

@end
