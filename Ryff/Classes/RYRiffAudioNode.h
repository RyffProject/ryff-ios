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

@protocol RYRiffAudioNodeDelegate <NSObject>
- (void)riffAudioFinished:(RYRiffAudioNode * __nonnull)node;
@end

typedef NS_ENUM(NSInteger, RYRiffAudioNodeStatus) {
    RYRiffAudioNodeStatusEmpty = 0,
    RYRiffAudioNodeStatusRecording,
    RYRiffAudioNodeStatusReadyToPlay,
    RYRiffAudioNodeStatusActive
};

typedef NS_ENUM(NSInteger, RYRiffActiveAudioNodeAction) {
    RYRiffActiveAudioNodeActionPlayingOnce = 0,
    RYRiffActiveAudioNodeActionLooping
};

@interface RYRiffAudioNode : NSObject

@property (nonatomic, assign) RYRiffAudioNodeStatus status;
@property (nonatomic, assign) RYRiffActiveAudioNodeAction activeAction;
@property (nonatomic, weak, nullable) id<RYRiffAudioNodeDelegate> delegate;

@property (nonatomic, readonly, nonnull) AVAudioPlayerNode *audioPlayerNode;
@property (nonatomic, readonly, nullable) AVAudioPCMBuffer *audioBuffer;

- (nonnull instancetype)initWithDelegate:(id<RYRiffAudioNodeDelegate> __nullable)delegate NS_DESIGNATED_INITIALIZER;

- (void)setAudioBuffer:(AVAudioPCMBuffer * __nonnull)audioBuffer;
- (void)setAudioFile:(AVAudioFile * __nonnull)audioFile;
- (void)deleteAudio;

- (void)startWithDelay:(AVAudioTime * __nullable)delay looping:(BOOL)looping;

- (void)play;
- (void)pause;
- (void)stop;

@end
