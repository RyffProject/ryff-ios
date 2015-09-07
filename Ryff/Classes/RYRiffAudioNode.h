//
//  RYRiffAudioNode.h
//  Ryff
//
//  Created by Christopher Laganiere on 8/15/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

@import Foundation;

@class AVAudioPCMBuffer;
@class AVAudioPlayerNode;
@class AVAudioTime;
@class AVAudioFile;

typedef NS_ENUM(NSInteger, RYRiffAudioNodeStatus) {
    RYRiffAudioNodeStatusEmpty = 0,
    RYRiffAudioNodeStatusRecording,
    RYRiffAudioNodeStatusReadyToPlay,
    RYRiffAudioNodeStatusActive
};

typedef NS_ENUM(NSInteger, RYRiffActiveAudioNodeAction) {
    RYRiffActiveAudioNodeActionOnce = 0,
    RYRiffActiveAudioNodeActionLooping
};

@interface RYRiffAudioNode : NSObject

@property (nonatomic, assign) RYRiffAudioNodeStatus status;
@property (nonatomic, assign) RYRiffActiveAudioNodeAction activeAction;

@property (nonatomic, readonly, nonnull) AVAudioPlayerNode *audioPlayerNode;
@property (nonatomic, readonly, nullable) AVAudioPCMBuffer *audioBuffer;

- (void)setAudioBuffer:(AVAudioPCMBuffer * __nonnull)audioBuffer;
- (void)setAudioFile:(AVAudioFile * __nonnull)audioFile;
- (void)deleteAudio;

- (void)startWithDelay:(AVAudioTime * __nullable)delay looping:(BOOL)looping;

- (void)play;
- (void)pause;
- (void)stop;

@end
