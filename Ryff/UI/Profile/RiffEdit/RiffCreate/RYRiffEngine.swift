//
//  RYRiffEngine.swift
//  Ryff
//
//  Created by Christopher Laganiere on 10/3/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

import UIKit
import AVFoundation

protocol RiffEngineTrackDelegate: NSObjectProtocol {
    func tracksChanged()
    func trackChanged(track: RiffTrack)
}

protocol RiffEngineDeckDelegate: NSObjectProtocol {
    func activeTrackChanged()
    func controlsChanged()
}

class RiffTrack: NSObject {
    var audioNode: AVAudioPlayerNode?
    var trackName: String?
    var trackAuthor: RYUser?
    
    init (trackName: String, trackAuthor: RYUser) {
        self.trackName = trackName
        self.trackAuthor = trackAuthor
        super.init()
    }
}

class RYRiffEngine: NSObject {
    
    let audioEngine:AVAudioEngine
    var audioTracks:Array<RiffTrack>
    var activeTrack:RiffTrack?
    weak var trackDelegate:RiffEngineTrackDelegate?
    weak var deckDelegate:RiffEngineDeckDelegate?
    
    override init() {
        audioEngine = AVAudioEngine()
        audioTracks = Array()
        super.init()
    }
    
    // MARK: Media Controls
    
    func addTrack(track:RiffTrack) {
        audioTracks.append(track)
    }
    
    // MARK: Active Track
    
    func addActiveToTracks() {
        if let newTrack = activeTrack {
            audioTracks.append(newTrack)
            activeTrack = nil
            trackDelegate?.tracksChanged()
            deckDelegate?.activeTrackChanged()
        }
    }
    
    func uploadActive() {
        if let newPost = activeTrack {
            // create new post and upload to server
        }
    }
}
