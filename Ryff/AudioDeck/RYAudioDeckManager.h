//
//  RYAudioDeckManager.h
//  Ryff
//
//  Created by Christopher Laganiere on 8/10/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTrackChangedNotification @"AudioDeckTrackChanged"
#define kPlaylistChangedNotification @"AudioDeckPlaylistChanged"
#define kPlaybackChangedNotification @"AudioDeckPlaybackChanged"
#define kDownloadProgressNotification @"AudioDeckDownloadProgressChanged"

@class RYPost;

@protocol AudioDeckDelegate <NSObject>
@optional
- (void) riffPlaylistUpdated;
- (void) trackChanged;
- (void) post:(RYPost *)post playbackTimeChanged:(CGFloat)time progress:(CGFloat)progress;
- (void) post:(RYPost *)post downloadProgressChanged:(CGFloat)progress;
@end

@interface RYAudioDeckManager : NSObject

@property (nonatomic, weak) id<AudioDeckDelegate> delegate;

+ (instancetype) sharedInstance;

// Media Control
- (void) playTrack:(BOOL)playTrack;
- (void) setPlaybackProgress:(CGFloat)progress;
- (void) skipTrack;

// Media
- (CGFloat) currentPlaybackProgress;
- (BOOL) isPlaying;

// Data Control
- (void) forcePostToTop:(RYPost *)post;
- (void) addPostToPlaylist:(RYPost *)post;
- (void) movePostFromPlaylistIndex:(NSInteger)playlistIdx toIndex:(NSInteger)newPlaylistIdx;
- (void) removePostFromPlaylist:(RYPost *)post;
- (NSInteger) idxOfDownload:(RYPost *)post;
- (NSInteger) idxInPlaylistOfPost:(RYPost *)post;
- (BOOL) playlistContainsPost:(NSInteger)postID;
- (BOOL) playlistContainsFile:(NSString *)fileName;

// Data
- (RYPost *)currentlyPlayingPost;
- (NSArray *)riffPlaylist;
- (NSArray *)downloadQueue;

@end
