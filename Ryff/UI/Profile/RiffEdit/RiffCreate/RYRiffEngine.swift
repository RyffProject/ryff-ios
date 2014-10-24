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
    }
    
    convenience init(trackName: String, audioURL:NSURL, audioEngine: AVAudioEngine) {
        self.init(trackName:trackName, trackAuthor:RYRegistrationServices.loggedInUser(), audioNode:AVAudioPlayerNode(), audioFile:AVAudioFile(forReading: audioURL, error: nil))
    }
    
    func position() -> CGFloat {
        let length = CGFloat(audioFile.length)
        let lastPosition = CGFloat(audioNode.lastRenderTime.sampleTime)
        return lastPosition/length
    }
    
    func skipToPosition(percentFinished:CGFloat) {
        let length = CGFloat(audioFile.length)
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
            audioEngine.stop()
            audioEngine.mainMixerNode.removeTapOnBus(0)
            let audioURL = audioFile.url.filePathURL!
            activeTrack = RiffTrack(trackName: "Track \(audioTracks.count+1)", audioURL: audioURL, audioEngine: audioEngine)
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
            
            var audioError:NSError?
            
            let settings = [AVFormatIDKey: kAudioFormatMPEG4AAC, AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.0, AVEncoderBitRatePerChannelKey: 16, AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue]
            recordingFile = AVAudioFile(forWriting: RYDataManager.urlForNextTrack(), settings: settings, error: &audioError)
            audioEngine.mainMixerNode.installTapOnBus(0, bufferSize: 4096, format: audioEngine.mainMixerNode.inputFormatForBus(0), block: { (buffer, when) -> Void in
                var error:NSError?
                self.recordingFile?.writeFromBuffer(buffer, error: &error)
                if (error != nil) {
                    println(error?.localizedDescription)
                }
            })
            audioEngine.startAndReturnError(nil)
            recording = true
            
            if let err = audioError {
                println(err.localizedDescription)
            }
        }
    }
    
    func uploadActive() {
        if let newPost = activeTrack {
            // create new post and upload to server
        }
    }
}
