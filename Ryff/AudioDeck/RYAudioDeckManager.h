//
//  RYAudioDeckManager.h
//  Ryff
//
//  Created by Christopher Laganiere on 8/10/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RYNewsfeedPost;

@protocol AudioDeckDelegate <NSObject>
@optional
- (void) riffPlaylistUpdated;
- (void) trackChanged;
- (void) post:(RYNewsfeedPost *)post playbackTimeChanged:(CGFloat)time progress:(CGFloat)progress;
- (void) post:(RYNewsfeedPost *)post downloadProgressChanged:(CGFloat)progress;
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
- (CGFloat) currentVolume;
- (BOOL) isPlaying;

// Data Control
- (void) forcePostToTop:(RYNewsfeedPost *)post;
- (void) addPostToPlaylist:(RYNewsfeedPost *)post;
- (void) removePostFromPlaylist:(RYNewsfeedPost *)post;

// Data
- (RYNewsfeedPost *)currentlyPlayingPost;
- (NSArray *)riffPlaylist;
- (NSArray *)downloadQueue;

@end
