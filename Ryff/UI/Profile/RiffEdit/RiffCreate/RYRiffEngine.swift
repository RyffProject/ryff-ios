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
    func activeTrackProgressChanged()
    func controlsChanged()
}

class RiffTrack: NSObject {
    let audioFile: AVAudioFile
    let audioNode: AVAudioPlayerNode
    var trackName: String?
    var trackAuthor: RYUser?
    
    init(trackName: String, trackAuthor: RYUser, audioNode: AVAudioPlayerNode, audioFile: AVAudioFile) {
        self.trackName   = trackName
        self.trackAuthor = trackAuthor
        self.audioNode   = audioNode
        self.audioFile   = audioFile
        super.init()
        
        audioNode.play()
    }
    
    convenience init(trackName: String, audioURL:NSURL) {
        self.init(trackName:trackName, trackAuthor:RYRegistrationServices.loggedInUser(), audioNode:AVAudioPlayerNode(), audioFile:AVAudioFile(forReading: audioURL, error: nil))
    }
    
    func position() -> Double {
        let length:NSNumber = Int(audioFile.length)
        let lastPosition:NSNumber = Int(audioNode.lastRenderTime.sampleTime)
        return lastPosition/length
    }
    
    func skipToPosition(percentFinished:CGFloat) {
        let length:NSNumber = Int(audioFile.length)
        let sampleTime = Int64(percentFinished*length)
        let audioTime = AVAudioTime(sampleTime: sampleTime, atRate: audioFile.processingFormat.sampleRate)
        audioNode.playAtTime(audioTime)
    }
}

class RYRiffEngine: NSObject {
    
    let audioEngine:AVAudioEngine
    var audioTracks:Array<RiffTrack>
    var activeTrack:RiffTrack?
    var recording:Bool
    weak var trackDelegate:RiffEngineTrackDelegate?
    weak var deckDelegate:RiffEngineDeckDelegate?
    
    private var recordingFile:AVAudioFile?
    
    override init() {
        audioEngine = AVAudioEngine()
        audioTracks = Array()
        recording = false
        super.init()
        
        audioEngine.startAndReturnError(nil)
    }
    
    // MARK: Media Controls
    
    func addTrack(track: RiffTrack) {
        audioTracks.append(track)
        audioEngine.attachNode(track.audioNode)
        
        trackDelegate?.tracksChanged()
        deckDelegate?.activeTrackChanged()
    }
    
    // MARK: Active Track
    
    func recordActive() {
        if let audioFile = recordingFile {
            // finish recording
            activeTrack = RiffTrack(trackName: "Track \(audioTracks.count+1)", audioURL: audioFile.url)
            recordingFile = nil
            recording = false
            
            // notify delegate
            deckDelegate?.activeTrackChanged()
        }
        else {
            // start recording
            if let newTrack = activeTrack {
                self.addTrack(newTrack)
                activeTrack = nil
            }
            
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
    
    func uploadActive() {
        if let newPost = activeTrack {
            // create new post and upload to server
        }
    }
}
