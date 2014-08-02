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
#import "RYRiffCell.h"
#import "RYStyleSheet.h"

// Data Managers
#import "RYServices.h"

// Data Objects
#import "RYNewsfeedPost.h"
#import "RYRiff.h"
#import "RYUser.h"

#define kRiffCellReuseID @"RiffCell"

@class AVAudioPlayer;

@interface RYRiffStreamingCoreViewController : RYCoreViewController <UpvoteDelegate>

// Audio
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSMutableData *riffData;
@property (nonatomic, strong) NSURLConnection *riffConnection;
@property (nonatomic, assign) CGFloat totalBytes;
@property (nonatomic, weak) RYRiffCell *currentlyPlayingCell;
@property (nonatomic, assign) BOOL isDownloading;

@property (nonatomic, strong) UITableView *riffTableView;
@property (nonatomic, strong) NSArray *feedItems;
@property (nonatomic, assign) NSInteger riffSection;

- (void) startRiffDownload:(RYRiff*)riff;
- (void) clearRiff;
- (void)updateTimeLeft;

// Table Override Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
