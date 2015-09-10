//
//  RYAudioDeck.swift
//  Ryff
//
//  Created by Christopher Laganiere on 9/7/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import SDWebImage

protocol AVAudioDeckDelegate: class {
    
    /**
    Current playing status of the Audio Deck changed.
    The currently playing post is implied to be the same, but the deck's play/pause/progress status changed.
    */
    func playbackStatusChanged()
    
    /**
    The currently playing post changed.
    */
    func currentlyPlayingChanged()
    
    /**
    The current playlist changed.
    */
    func playlistChanged()
}

class RYAudioDeck : NSObject, RYAudioDeckPlaylistDelegate, AVAudioPlayerDelegate {
    
    let PlaylistChangedNotification = "AudioDeckPlaylistChanged"
    let CurrentlyPlayingChangedNotification = "AudioDeckCurrentlyPlayingChanged"
    let PlaybackProgressUpdateTimeInterval: NSTimeInterval = 0.1
    
    static let sharedAudioDeck = RYAudioDeck()
    
    @objc(isPlaying)
    var playing : Bool {
        get {
            return audioPlayer?.playing ?? false
        }
    }
    var playbackProgress: CGFloat {
        get {
            if let player = audioPlayer {
                return CGFloat(player.currentTime) / CGFloat(max(1,player.duration))
            }
            return 0.0
        }
        set {
            if let player = audioPlayer {
                player.currentTime = NSTimeInterval(playbackProgress*CGFloat(player.duration))
                playbackStatusChanged()
            }
        }
    }
    
    private(set) var currentPlaylist: RYAudioDeckPlaylist?
    private(set) var currentlyPlaying: RYPost? {
        didSet {
            updateNowPlayingInfo(true)
            delegate?.currentlyPlayingChanged()
            // Post notification so UI can adjust if needed.
            NSNotificationCenter.defaultCenter().postNotificationName(CurrentlyPlayingChangedNotification, object: nil)
        }
    }
    
    private weak var delegate: AVAudioDeckDelegate?
    private let defaultPlaylist = RYAudioDeckPlaylist()
    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: NSTimer?
    private var nowPlayingImage: UIImage?
    private var nowPlayingDict: [String: AnyObject] = [:]
    
    override init() {
        super.init()
        defaultPlaylist.playlistDelegate = self
        currentPlaylist = defaultPlaylist
        
        // Set up timer to update now playing information and notify UI regularly.
        let progressTimer = NSTimer.scheduledTimerWithTimeInterval(PlaybackProgressUpdateTimeInterval, target: self, selector: Selector("updateProgress:"), userInfo: nil, repeats: true)
        // Add timer to current run loop to make sure UI updates even if a user touch is active.
        NSRunLoop.currentRunLoop().addTimer(progressTimer, forMode: NSRunLoopCommonModes)
        self.progressTimer = progressTimer
        
        // Set up AVAudioSession
        let audioSession = AVAudioSession.sharedInstance()
        if !audioSession.setCategory(AVAudioSessionCategoryPlayback, error: nil) {
            println("Something went wrong setting audio session category")
        }
        if !audioSession.setActive(true, error: nil) {
            println("Something went wrong setting audio session active")
        }
    }
    
    // MARK: Public
    
    func play() {
        if let player = audioPlayer {
            if !player.playing {
                player.play()
                playbackStatusChanged()
            }
        }
        else {
            playNextTrack()
        }
    }
    
    func pause() {
        if let player = audioPlayer where player.playing {
            player.pause()
            playbackStatusChanged()
        }
    }
    
    func skip() {
        playNextTrack()
    }
    
    // MARK: RYAudioDeckPlaylistDelegate
    
    func playlistChanged() {
        // Play next post if added.
        if currentlyPlaying == nil {
            // play next song
            playNextTrack()
        }
        // Or else if the currently playing isn't at the top of the playlist anymore, go to the next one.
        if let currentlyPlaying = currentlyPlaying, firstInPlaylist = currentPlaylist?.readyPosts.first where currentlyPlaying != firstInPlaylist {
            stop()
            playNextTrack()
        }
        // Post notification so UI can update if needed.
        NSNotificationCenter.defaultCenter().postNotificationName(PlaylistChangedNotification, object: nil)
    }
    
    // MARK: AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        playNextTrack()
    }
    
    // MARK: Private
    
    /**
    Stop the currently playing post if relevant and start playing the next post if possible.
    */
    private func playNextTrack() {
        if let _ = currentlyPlaying {
            stop()
        }
        
        if let nextPost = currentPlaylist?.readyPosts.first {
            playPost(nextPost)
        }
    }
    
    /**
    Set up a post to play. Once playPost() is called to set up Audio Deck for this post, use pause() and play() to
    adjust playback, and stop() to finish it.
    
    :param: post RYPost to play.
    */
    private func playPost(post: RYPost) {
        if let _ = audioPlayer {
            return
        }
        
        let localURL = RYDataManager.urlForTempRiff(post.riffHQURL)
        if let localPath = localURL.path where NSFileManager.defaultManager().fileExistsAtPath(localPath) {
            audioPlayer = AVAudioPlayer(contentsOfURL: localURL, error: nil)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            currentlyPlaying = post
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            updateNowPlayingInfo(true)
            playbackStatusChanged()
            
            // Start downloading image data for this post and update now playing when it finishes downloading
            if (post.imageURL != nil || post.user.avatarURL != nil) {
                let imageURL = post.imageURL ?? post.user.avatarURL
                weak var weakself = self
                SDWebImageManager.sharedManager().downloadImageWithURL(imageURL, options: nil, progress: nil, completed: { (image, error, cacheType, finished, imageURL) -> Void in
                    if let error = error {
                        println("Couldn't download image for post: \(error.localizedDescription)")
                    }
                    else {
                        weakself?.nowPlayingImage = image
                        weakself?.updateNowPlayingInfo(true)
                    }
                })
            }
        }
    }
    
    /**
    Stop the currently playing post and clear meta data.
    Cleans up after playPost(). Should be called after each track is finished playing.
    */
    private func stop() {
        if let player = audioPlayer {
            player.stop()
            audioPlayer = nil
        }
        if let currentlyPlaying = currentlyPlaying {
            if let firstInPlaylist = currentPlaylist?.readyPosts.first where currentlyPlaying == firstInPlaylist {
                currentPlaylist?.removePost(firstInPlaylist)
            }
            
            self.currentlyPlaying = nil
            playbackStatusChanged()
        }
        
    }
    
    /**
    Called whenever playback status changes at all - even every second as playback time progresses.
    */
    private func playbackStatusChanged() {
        updateNowPlayingInfo(false)
        delegate?.playbackStatusChanged()
    }
    
    /**
    Update the system now playing information (MPMediaItemProperty) with self.currentlyPlaying.
    
    :param: updateTrackInfo Should update artist, image, and track name in addition to the playback status.
    */
    private func updateNowPlayingInfo(updateTrackInfo: Bool) {
        if let currentlyPlaying = currentlyPlaying {
            if (updateTrackInfo) {
                nowPlayingDict[MPMediaItemPropertyArtist] = currentlyPlaying.user.username
                nowPlayingDict[MPMediaItemPropertyTitle] = currentlyPlaying.title
                if let nowPlayingImage = nowPlayingImage {
                    nowPlayingDict[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: nowPlayingImage)
                }
            }
            
            if let audioPlayer = audioPlayer {
                nowPlayingDict[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration
                nowPlayingDict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
            }
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nowPlayingDict
        }
    }
    
    // MARK: Timer
    
    func updateProgress(timer: NSTimer) {
        if let player = audioPlayer where player.playing {
            playbackStatusChanged()
        }
    }
    
}
