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
#import "RYUser.h"

// Frameworks
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#define kAudioDeckVolumeKey @"PreferredAudioDeckVolume"

@interface RYAudioDeckManager () <AVAudioPlayerDelegate, TrackDownloadDelegate>

// both data arrays populated with RYNewsfeedPost objects
@property (nonatomic, strong) NSMutableArray *riffPlaylist;
@property (nonatomic, strong) NSMutableArray *downloadQueue;
@property (nonatomic, strong) RYNewsfeedPost *currentlyPlayingPost;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) CGFloat globalVolume;

@property (nonatomic, strong) NSTimer *updatePlaybackTimer;

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
        
        NSNumber *preferredVolume = [[NSUserDefaults standardUserDefaults] objectForKey:kAudioDeckVolumeKey];
        if (preferredVolume)
            _sharedInstance.globalVolume = preferredVolume.floatValue;
        else
            _sharedInstance.globalVolume = 1.0f;
        
        _sharedInstance.updatePlaybackTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:_sharedInstance selector:@selector(updatePlaybackProgress:) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:_sharedInstance.updatePlaybackTimer forMode:NSRunLoopCommonModes];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *setCategoryError = nil;
        BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
        if (!success)
            NSLog(@"error: %@",[setCategoryError localizedDescription]);
        
        NSError *activationError = nil;
        success = [audioSession setActive:YES error:&activationError];
        if (!success)
            NSLog(@"error: %@",[activationError localizedDescription]);
    }
    return _sharedInstance;
}

#pragma mark -
#pragma mark - Media Control

- (void) playTrack:(BOOL)playTrack
{
    if (playTrack)
    {
        if (_audioPlayer)
        {
            if (!_audioPlayer.isPlaying)
                [_audioPlayer play];
        }
        else
        {
            [self playNextTrack];
        }
    }
    else
    {
        if (_audioPlayer.isPlaying)
            [_audioPlayer pause];
    }
    
    [self notifyTrackChanged];
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
    _globalVolume = volume;
    if (_audioPlayer)
        [_audioPlayer setVolume:_globalVolume];
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

- (void) notifyTrackChanged
{
    if (_delegate && [_delegate respondsToSelector:@selector(trackChanged)])
        [_delegate trackChanged];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTrackChangedNotification object:@{@"trackChanged":@(true)}];
}

- (void) playPost:(RYNewsfeedPost *)post
{
    NSURL *localURL = [RYDataManager urlForTempRiff:post.riff.fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localURL.path])
    {
        // confirmed that media file exists
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:localURL error:NULL];
        _audioPlayer.delegate = self;
        _audioPlayer.volume = _globalVolume;
        [_audioPlayer play];
        _currentlyPlayingPost = post;
        
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self notifyTrackChanged];
        [self updateNowPlaying];
    }
}

- (void) stopPost
{
    if (_audioPlayer)
    {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
    
    if (_currentlyPlayingPost)
    {
        _currentlyPlayingPost = nil;
        
        [self notifyTrackChanged];
        [self updateNowPlaying];
    }
}

- (void) playNextTrack
{
    if (_riffPlaylist.count > 0)
    {
        if (((RYNewsfeedPost*)_riffPlaylist[0]).postId == _currentlyPlayingPost.postId)
        {
            // first track in playlist is also currently playing one -> should remove it
            [_riffPlaylist removeObjectAtIndex:0];
            
            [self notifyPlaylistChanged];
        }
        
        [self stopPost];
        
        if (_riffPlaylist.count > 0)
        {
            // more in playlist -> start new track playing
            [self playPost:_riffPlaylist[0]];
        }
    }
    else
        [self stopPost];
}

- (void) updateNowPlaying
{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter && _currentlyPlayingPost)
    {
        NSString *artist = _currentlyPlayingPost.user.nickname.length > 0 ? _currentlyPlayingPost.user.nickname : _currentlyPlayingPost.user.username;
        NSMutableDictionary *nowPlaying = [@{MPMediaItemPropertyArtist: artist,
                                     MPMediaItemPropertyAlbumTitle: _currentlyPlayingPost.riff.title} mutableCopy];
        if (_audioPlayer)
        {
            [nowPlaying setObject:@(_audioPlayer.duration) forKey:MPMediaItemPropertyPlaybackDuration];
            [nowPlaying setObject:@(_audioPlayer.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        }
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlaying];
    }
}

- (void) updatePlaybackProgress:(NSTimer *)timer
{
    if (_audioPlayer && _audioPlayer.isPlaying)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(post:playbackTimeChanged:progress:)])
        {
            CGFloat progress = _audioPlayer.currentTime / _audioPlayer.duration;
            [_delegate post:_currentlyPlayingPost playbackTimeChanged:_audioPlayer.currentTime progress:progress];
            [self updateNowPlaying];
        }
    }
}

#pragma mark -
#pragma mark - Data Control

- (void) forcePostToTop:(RYNewsfeedPost *)post
{
    [self stopPost];
    _currentlyPlayingPost = post;
    
    NSInteger idxInPlaylist = [self idxInPlaylistOfPost:post];
    if (idxInPlaylist >= 0)
    {
        // already downloaded, play
        [_riffPlaylist removeObjectAtIndex:idxInPlaylist];
        [_riffPlaylist insertObject:post atIndex:0];
        
        [self notifyPlaylistChanged];
        
        [self playPost:post];
    }
    else if ([self idxOfDownload:post] == -1)
    {
        // not downloading yet either
        [self addPostToPlaylist:post];
    }
}

- (void) addPostToPlaylist:(RYNewsfeedPost *)post
{
    if (!post)
        return;
    
    // make sure not already in playlist
    NSArray *processedPosts = [_riffPlaylist arrayByAddingObjectsFromArray:_downloadQueue];
    for (RYNewsfeedPost *exitingPost in processedPosts)
    {
        if (post.postId == exitingPost.postId)
            return;
    }
    
    // start download
    [_downloadQueue addObject:post];
    
    [self notifyPlaylistChanged];
    
    [[RYDataManager sharedInstance] fetchTempRiff:post.riff forDelegate:self];
}

- (void) movePostFromPlaylistIndex:(NSInteger)playlistIdx toIndex:(NSInteger)newPlaylistIdx
{
    if (newPlaylistIdx < _riffPlaylist.count && playlistIdx < _riffPlaylist.count)
    {
        RYNewsfeedPost *post = _riffPlaylist[playlistIdx];
        [_riffPlaylist removeObjectAtIndex:playlistIdx];
        [_riffPlaylist insertObject:post atIndex:newPlaylistIdx];
        
        if (post.postId == _currentlyPlayingPost.postId)
            [self stopPost];
        
        [self notifyPlaylistChanged];
    }
}

- (void) removePostFromPlaylist:(RYNewsfeedPost *)post
{
    if (post.postId == _currentlyPlayingPost.postId)
        [self playNextTrack];
    
    // remove from _riffPlaylist if there
    for (RYNewsfeedPost *exitingPost in _riffPlaylist)
    {
        if (post.postId == exitingPost.postId)
        {
            [_riffPlaylist removeObject:exitingPost];
            
            [self notifyPlaylistChanged];
            
            return;
        }
    }
    // remove from _downloadQueue if there
    for (RYNewsfeedPost *exitingPost in _downloadQueue)
    {
        if (post.postId == exitingPost.postId)
        {
            [_downloadQueue removeObject:exitingPost];
            
            [self notifyPlaylistChanged];
            
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

- (NSInteger) idxInPlaylistOfPost:(RYNewsfeedPost *)post
{
    NSInteger idx = -1;
    for (RYNewsfeedPost *existingPost in _riffPlaylist)
    {
        if (existingPost.postId == post.postId)
        {
            idx = [_riffPlaylist indexOfObject:existingPost];
            break;
        }
    }
    return idx;
}

- (BOOL) playlistContainsPost:(NSInteger)postID
{
    BOOL postInPlaylist = NO;
    
    NSArray *allPosts = [_riffPlaylist arrayByAddingObjectsFromArray:_downloadQueue];
    for (RYNewsfeedPost *existingPost in allPosts)
    {
        if (existingPost.postId == postID)
        {
            postInPlaylist = YES;
            break;
        }
    }
    
    if (_currentlyPlayingPost.postId == postID)
        postInPlaylist = YES;
    
    return postInPlaylist;
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
            
            NSDictionary *notifDict = @{@"postID": @(post.postId), @"progress": @(progress)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadProgressNotification object:notifDict];
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
            
            if (trackURL == _currentlyPlayingPost.riff.URL)
            {
                [self playPost:_currentlyPlayingPost];
            }
            else
            {
                [_riffPlaylist addObject:post];
                
                if (!_audioPlayer)
                    [self playNextTrack];
            }
            
            [self notifyPlaylistChanged];
            break;
        }
    }
}

- (void) track:(NSURL *)trackURL DownloadFailed:(NSString *)reason
{
    for (RYNewsfeedPost *post in _downloadQueue)
    {
        if (post.riff.URL == trackURL)
        {
            [_downloadQueue removeObject:post];
            
            [self notifyPlaylistChanged];
            
            break;
        }
    }
}

#pragma mark - Internal

- (void) notifyPlaylistChanged
{
    if (_delegate && [_delegate respondsToSelector:@selector(riffPlaylistUpdated)])
        [_delegate riffPlaylistUpdated];
    
    NSDictionary *postDict = @{@"downloadQueueChanged":@(true)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kPlaylistChangedNotification object:postDict];
}

#pragma mark -
#pragma mark - AudioPlayer Delegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self playNextTrack];
}

@end
