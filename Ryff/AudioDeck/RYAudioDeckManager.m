//
//  RYAudioDeckManager.m
//  Ryff
//
//  Created by Christopher Laganiere on 8/10/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYAudioDeckManager.h"

// Data Managers
#import "RYDataManager.h"

// Data Objects
#import "RYNewsfeedPost.h"
#import "RYRiff.h"

// Frameworks
#import <AVFoundation/AVFoundation.h>

@interface RYAudioDeckManager () <AVAudioPlayerDelegate, TrackDownloadDelegate>

// both data arrays populated with RYNewsfeedPost objects
@property (nonatomic, strong) NSMutableArray *riffPlaylist;
@property (nonatomic, strong) NSMutableArray *downloadQueue;
@property (nonatomic, strong) RYNewsfeedPost *currentlyPlayingPost;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) CGFloat globalVolume;

@end

@implementation RYAudioDeckManager

static RYAudioDeckManager *_sharedInstance;
+ (instancetype)sharedInstance
{
    if (_sharedInstance == NULL)
    {
        _sharedInstance = [RYAudioDeckManager allocWithZone:NULL];
        _sharedInstance.downloadQueue = [[NSMutableArray alloc] init];
        _sharedInstance.riffPlaylist  = [[NSMutableArray alloc] init];
    }
    return _sharedInstance;
}

#pragma mark -
#pragma mark - Media Control
- (void) playTrack:(BOOL)playTrack
{
    if (playTrack)
    {
        if (_audioPlayer && !_audioPlayer.isPlaying)
            [_audioPlayer play];
    }
    else
    {
        if (_audioPlayer.isPlaying)
        {
            [_audioPlayer pause];
            
            if (_delegate && [_delegate respondsToSelector:@selector(trackChanged)])
                [_delegate trackChanged];
        }
    }
}

- (void) setPlaybackProgress:(CGFloat)progress
{
    if (_audioPlayer)
    {
        CGFloat playbackTime = progress*_audioPlayer.duration;
        [_audioPlayer setCurrentTime:playbackTime];
        if (_delegate && [_delegate respondsToSelector:@selector(post:playbackTimeChanged:progress:)])
            [_delegate post:_currentlyPlayingPost playbackTimeChanged:playbackTime progress:progress];
    }
}

- (void) setVolume:(CGFloat)volume
{
    if (_audioPlayer)
    {
        _globalVolume = volume;
        [_audioPlayer setVolume:_globalVolume];
    }
}

- (void) skipTrack
{
    [self playNextTrack];
}

#pragma mark - Media

- (CGFloat) currentPlaybackProgress
{
    return _audioPlayer ? (_audioPlayer.currentTime/_audioPlayer.duration) : 0;
}

- (CGFloat) currentVolume
{
    return _globalVolume;
}

- (BOOL) isPlaying
{
    return _audioPlayer.isPlaying;
}

#pragma mark - Internal Helpers

- (void) playPost:(RYNewsfeedPost *)post
{
    NSURL *localURL = [RYDataManager urlForTempRiff:post.riff.fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localURL.path])
    {
        // confirmed that media file exists
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:localURL error:NULL];
        [_audioPlayer play];
        _currentlyPlayingPost = post;
        
        if (_delegate && [_delegate respondsToSelector:@selector(trackChanged)])
            [_delegate trackChanged];
    }
}

- (void) stopPost
{
    if (_audioPlayer)
    {
        [_audioPlayer stop];
        _audioPlayer = nil;
        
        if (_delegate && [_delegate respondsToSelector:@selector(trackChanged)])
            [_delegate trackChanged];
    }
    _currentlyPlayingPost = nil;
}

- (void) playNextTrack
{
    if (_riffPlaylist.count > 0)
    {
        if (((RYNewsfeedPost*)_riffPlaylist[0]).postId == _currentlyPlayingPost.postId)
        {
            // first track in playlist is also currently playing one -> should remove it
            [_riffPlaylist removeObjectAtIndex:0];
            
            if (_delegate && [_delegate respondsToSelector:@selector(riffPlaylistUpdated)])
                [_delegate riffPlaylistUpdated];
        }
        
        [self stopPost];
        
        if (_riffPlaylist.count > 0)
        {
            // more in playlist -> start new track playing
            [self playPost:_riffPlaylist[0]];
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(trackChanged)])
        [_delegate trackChanged];
}

#pragma mark -
#pragma mark - Data Control

- (void) forcePostToTop:(RYNewsfeedPost *)post
{
    [self stopPost];
    _currentlyPlayingPost = post;
    [[RYDataManager sharedInstance] fetchTempRiff:post.riff forDelegate:self];
}

- (void) addPostToPlaylist:(RYNewsfeedPost *)post
{
    // make sure not already in playlist
    NSArray *processedPosts = [_riffPlaylist arrayByAddingObjectsFromArray:_downloadQueue];
    for (RYNewsfeedPost *exitingPost in processedPosts)
    {
        if (post.postId == exitingPost.postId)
            return;
    }
    
    // start download
    [_downloadQueue addObject:post];
    if (_delegate && [_delegate respondsToSelector:@selector(riffPlaylistUpdated)])
        [_delegate riffPlaylistUpdated];
    
    [[RYDataManager sharedInstance] fetchTempRiff:post.riff forDelegate:self];
}

- (void) removePostFromPlaylist:(RYNewsfeedPost *)post
{
    if (post.postId == _currentlyPlayingPost.postId)
        [self stopPost];
    
    // remove from _riffPlaylist if there
    for (RYNewsfeedPost *exitingPost in _riffPlaylist)
    {
        if (post.postId == exitingPost.postId)
        {
            [_riffPlaylist removeObject:exitingPost];
            return;
        }
    }
    // remove from _downloadQueue if there
    for (RYNewsfeedPost *exitingPost in _downloadQueue)
    {
        if (post.postId == exitingPost.postId)
        {
            [_downloadQueue removeObject:exitingPost];
            return;
        }
    }
}

- (NSInteger) idxOfDownload:(RYNewsfeedPost *)post
{
    NSInteger idx = -1;
    for (RYNewsfeedPost *existingPost in _downloadQueue)
    {
        if (existingPost.postId == post.postId)
        {
            idx = [_downloadQueue indexOfObject:existingPost];
            break;
        }
    }
    return idx;
}

#pragma mark - Data

- (RYNewsfeedPost *)currentlyPlayingPost
{
    return _currentlyPlayingPost;
}

- (NSArray *)riffPlaylist
{
    return _riffPlaylist;
}

- (NSArray *)downloadQueue
{
    return _downloadQueue;
}

#pragma mark -
#pragma mark - TrackDownload Delegate

- (void) track:(NSURL *)trackURL DownloadProgressed:(CGFloat)progress
{
    for (RYNewsfeedPost *post in _downloadQueue)
    {
        if (post.riff.URL == trackURL)
        {
            if (_delegate && [_delegate respondsToSelector:@selector(post:downloadProgressChanged:)])
                [_delegate post:post downloadProgressChanged:progress];
        }
    }
}

- (void) track:(NSURL *)trackURL FinishedDownloading:(NSURL *)localURL
{
    for (RYNewsfeedPost *post in _downloadQueue)
    {
        if (post.riff.URL == trackURL)
        {
            [_downloadQueue removeObject:post];
            [_riffPlaylist addObject:post];
            if (_delegate && [_delegate respondsToSelector:@selector(riffPlaylistUpdated)])
                [_delegate riffPlaylistUpdated];
            
            if (!_audioPlayer)
                [self playNextTrack];
            
            return;
        }
    }
    
    // not in download queue, could be _currentlyPlayingTrack
    if (trackURL == _currentlyPlayingPost.riff.URL)
    {
        // shortcutted track, should start playing
        [self stopPost];
        [self playPost:_currentlyPlayingPost];
    }
}

- (void) track:(NSURL *)trackURL DownloadFailed:(NSString *)reason
{
    for (RYNewsfeedPost *post in _downloadQueue)
    {
        if (post.riff.URL == trackURL)
        {
            [_downloadQueue removeObject:post];
            if (_delegate && [_delegate respondsToSelector:@selector(riffPlaylistUpdated)])
                [_delegate riffPlaylistUpdated];
            
            break;
        }
    }
}

#pragma mark -
#pragma mark - AudioPlayer Delegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self playNextTrack];
}

@end
