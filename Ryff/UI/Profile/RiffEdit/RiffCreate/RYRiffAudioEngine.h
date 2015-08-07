//
//  RYRiffAudioEngine.h
//  Ryff
//
//  Created by Christopher Laganiere on 12/22/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

@import Foundation;

// effect strip 1 - Marimba Player -> Delay -> Mixer
// effect strip 2 - Drum Player -> Reverb -> Mixer

@protocol AudioEngineDelegate <NSObject>

@optional
- (void)engineWasInterrupted;
- (void)engineConfigurationHasChanged;
- (void)mixerOutputFilePlayerHasStopped;

@end

@interface RYRiffAudioEngine : NSObject

@property (nonatomic, readonly) BOOL marimbaPlayerIsPlaying;
@property (nonatomic, readonly) BOOL drumPlayerIsPlaying;

@property (nonatomic) float marimbaPlayerVolume;    // 0.0 - 1.0
@property (nonatomic) float drumPlayerVolume;       // 0.0 - 1.0

@property (nonatomic) float marimbaPlayerPan;       // -1.0 - 1.0
@property (nonatomic) float drumPlayerPan;          // -1.0 - 1.0

@property (nonatomic) float delayWetDryMix;         // 0.0 - 1.0
@property (nonatomic) BOOL bypassDelay;

@property (nonatomic) float reverbWetDryMix;        // 0.0 - 1.0
@property (nonatomic) BOOL bypassReverb;

@property (nonatomic) float outputVolume;           // 0.0 - 1.0

@property (weak) id<AudioEngineDelegate> delegate;


- (void)toggleMarimba;
- (void)toggleDrums;

- (void)startRecordingMixerOutput;
- (void)stopRecordingMixerOutput;
- (void)playRecordedFile;
- (void)pausePlayingRecordedFile;
- (void)stopPlayingRecordedFile;

@end