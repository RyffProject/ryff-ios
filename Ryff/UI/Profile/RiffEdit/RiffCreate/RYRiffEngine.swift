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
    
    init(trackName: String, trackAuthor: RYUser, audioNode:AVAudioPlayerNode) {
        self.trackName = trackName
        self.trackAuthor = trackAuthor
        super.init()
    }
    
    convenience init(buffer:AVAudioPCMBuffer) {
        self.init(trackName:"New", trackAuthor:RYRegistrationServices.loggedInUser(), audioNode:AVAudioPlayerNode())
        audioNode?.scheduleBuffer(buffer, atTime: nil, options: .Loops, completionHandler: nil)
    }
}

class RYRiffEngine: NSObject {
    
    let audioEngine:AVAudioEngine
    var audioTracks:Array<RiffTrack>
    var activeTrack:RiffTrack?
    var recordingFile:AVAudioFile?
    var recording:Bool
    weak var trackDelegate:RiffEngineTrackDelegate?
    weak var deckDelegate:RiffEngineDeckDelegate?
    
    override init() {
        audioEngine = AVAudioEngine()
        audioTracks = Array()
        recording = false
        super.init()
    }
    
    // MARK: Media Controls
    
    func addTrack(track:RiffTrack) {
        audioTracks.append(track)
    }
    
    // MARK: Active Track
    
    func recordActive() {
        if (recordingFile != nil) {
            // finish recording
            let buffer = AVAudioPCMBuffer()
            recordingFile?.readIntoBuffer(buffer, error: nil)
            activeTrack = RiffTrack(buffer:buffer)
            recordingFile = nil
            recording = false
        }
        else {
            // start recording
            recordingFile = AVAudioFile()
            audioEngine.inputNode.installTapOnBus(0, bufferSize: 4096, format: audioEngine.inputNode.inputFormatForBus(0), block: { (buffer, when) -> Void in
                var error:NSError?
                self.recordingFile?.writeFromBuffer(buffer, error: &error)
                if (error != nil) {
                    println(error?.localizedDescription)
                }
            })
            recording = true
        }
    }
    
    func addTrackToTracks(track: RiffTrack) {
        if let playerNode = track.audioNode {
            audioTracks.append(track)
            activeTrack = nil
            
            audioEngine.attachNode(playerNode)
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
