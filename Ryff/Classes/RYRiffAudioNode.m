//
//  RYRiffAudioNode.m
//  Ryff
//
//  Created by Christopher Laganiere on 8/15/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

#import "RYRiffAudioNode.h"

@import AVFoundation;

@interface RYRiffAudioNode ()

@property (nonatomic, nonnull) AVAudioPlayerNode *audioPlayerNode;
@property (nonatomic, nullable) AVAudioPCMBuffer *audioBuffer;

@end

@implementation RYRiffAudioNode

- (instancetype)init {
    if (self = [super init]) {
        _audioPlayerNode = [[AVAudioPlayerNode alloc] init];
    }
    return self;
}

- (void)setAudioBuffer:(AVAudioPCMBuffer * __nonnull)audioBuffer {
    _audioBuffer = audioBuffer;
}

- (void)setAudioFile:(AVAudioFile * __nonnull)audioFile {
    NSError *error;
    AVAudioPCMBuffer *audioBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[audioFile processingFormat] frameCapacity:(AVAudioFrameCount)[audioFile length]];
    [audioFile readIntoBuffer:audioBuffer error:&error];
    _audioBuffer = audioBuffer;
}

- (void)deleteAudio {
    _audioBuffer = nil;
}

- (void)startWithDelay:(AVAudioTime * __nullable)delay looping:(BOOL)looping {
    AVAudioPlayerNodeBufferOptions options = looping ? AVAudioPlayerNodeBufferLoops : 0;
    [self.audioPlayerNode scheduleBuffer:self.audioBuffer atTime:delay options:options completionHandler:^{
        NSLog(@"schedule audio");
    }];
}

- (void)play {
    [self.audioPlayerNode play];
}

- (void)pause {
    [self.audioPlayerNode pause];
}

- (void)stop {
    [self.audioPlayerNode stop];
}

- (BOOL) isReadyToPlay {
    return (self.audioBuffer != NULL);
}

@end
