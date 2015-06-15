//
//  RYRiffAudioEngine.m
//  Ryff
//
//  Created by Christopher Laganiere on 12/22/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffAudioEngine.h"

#import <AVFoundation/AVFoundation.h>

@implementation RYRiffAudioEngine

+ (id)sharedManager {
    static RYRiffAudioEngine *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void) recordFile
{
    AVAudioEngine *audioEngine = [[AVAudioEngine alloc] init];
    AVAudioPlayerNode *playerNode = [[AVAudioPlayerNode alloc] init];
    [audioEngine attachNode:playerNode];
    [audioEngine connect:playerNode to:audioEngine.mainMixerNode format:[playerNode outputFormatForBus:0]];
    [audioEngine startAndReturnError:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [audioEngine stop];
    });
}

@end
