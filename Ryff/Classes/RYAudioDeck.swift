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
    func currentlyPlayingChanged()
}

class RYAudioDeck : NSObject, RYAudioDeckPlaylistDelegate, AVAudioPlayerDelegate {
    
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
                // TODO: notify delegate of playing change
            }
        }
    }
    
    private(set) var currentPlaylist: RYAudioDeckPlaylist?
    private(set) var currentlyPlaying: RYPost? {
        didSet {
            delegate?.currentlyPlayingChanged()
        }
    }
    
    private weak var delegate: AVAudioDeckDelegate?
    private let playlist = RYAudioDeckPlaylist()
    private var audioPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
        playlist.playlistDelegate = self
        currentPlaylist = playlist
    }
    
    // MARK: Public
    
    func play() {
        if let player = audioPlayer {
            if !player.playing {
                player.play()
                // TODO: notify delegate of playing change
            }
        }
        else {
            playNextTrack()
        }
    }
    
    func pause() {
        if let player = audioPlayer where player.playing {
            player.pause()
            // TODO: notify delegate of playing change
        }
    }
    
    func skip() {
        playNextTrack()
    }
    
    // MARK: RYAudioDeckPlaylistDelegate
    
    func playlistChanged() {
        if let currentlyPlaying = currentlyPlaying, firstInPlaylist = currentPlaylist?.readyPosts.first where currentlyPlaying != firstInPlaylist {
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
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            // TODO: notify delegate of playing change
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
            delegate?.currentlyPlayingChanged()
            // TODO: update now playing information
        }
    }
    
}
