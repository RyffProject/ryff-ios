//
//  RYRiffStreamingCoreViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYCoreViewController.h"

// Media
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

// Custom UI
#import "RYRiffTrackTableViewCell.h"
#import "RYStyleSheet.h"

// Data Objects
#import "RYNewsfeedPost.h"
#import "RYRiff.h"
#import "RYUser.h"

@class AVAudioPlayer;
@class RYRiffTrackTableViewCell;

@interface RYRiffStreamingCoreViewController : RYCoreViewController

// Audio
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSMutableData *riffData;
@property (nonatomic, strong) NSURLConnection *riffConnection;
@property (nonatomic, assign) CGFloat totalBytes;
@property (nonatomic, weak) RYRiffTrackTableViewCell *currentlyPlayingCell;
@property (nonatomic, assign) BOOL isDownloading, isPlaying;

@property (nonatomic, strong) UITableView *riffTableView;
@property (nonatomic, strong) NSArray *feedItems;

- (void) startRiffDownload:(RYRiff*)riff;
- (void) clearRiff;

@end
