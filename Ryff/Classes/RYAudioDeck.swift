//
//  RYAudioDeck.swift
//  Ryff
//
//  Created by Christopher Laganiere on 9/7/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import Foundation
import AVFoundation

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
            NSNotificationCenter.defaultCenter().postNotificationName(CurrentlyPlayingChangedNotification, object: nil)
        }
    }
    
    private weak var delegate: AVAudioDeckDelegate?
    private let defaultPlaylist = RYAudioDeckPlaylist()
    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: NSTimer?
    
    override init() {
        super.init()
        defaultPlaylist.playlistDelegate = self
        currentPlaylist = defaultPlaylist
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(PlaybackProgressUpdateTimeInterval, target: self, selector: Selector("updateProgress:"), userInfo: nil, repeats: true)
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
        if currentlyPlaying == nil {
            playNextTrack()
        }
        else if let currentlyPlaying = currentlyPlaying, firstInPlaylist = currentPlaylist?.readyPosts.first where currentlyPlaying != firstInPlaylist {
            stop()
        }
    }
    
    // MARK: AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        playNextTrack()
    }
    
    // MARK: Private
    
    private func playNextTrack() {
        if let _ = currentlyPlaying {
            stop()
        }
        
        if let nextPost = currentPlaylist?.readyPosts.first {
            playPost(nextPost)
        }
    }
    
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
            playbackStatusChanged()
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            // TODO: update now playing information
        }
    }
    
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
    
    private func playbackStatusChanged() {
        updateNowPlayingInfo(false)
        delegate?.playbackStatusChanged()
    }
    
    private func updateNowPlayingInfo(currentlyPlayingChanged: Bool) {
        
    }
    
    // MARK: Timer
    
    func updateProgress(timer: NSTimer) {
        if let player = audioPlayer where player.playing {
            playbackStatusChanged()
        }
    }
    
}
