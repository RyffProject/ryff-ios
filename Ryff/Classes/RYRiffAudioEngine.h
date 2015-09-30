//
//  RYRiffAudioEngine.h
//  Ryff
//
//  Created by Christopher Laganiere on 12/22/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

@import Foundation;

@class RYRiffAudioNode;

extern const NSString * __nonnull RecordingAudioFileFormat;

@protocol RiffAudioDataSource <NSObject>
- (nullable RYRiffAudioNode *)nodeAtIndex:(NSInteger)index;
- (void)toggleNodeAtIndex:(NSInteger)index;
- (void)clearNodeAtIndex:(NSInteger)index;
- (void)playNodeAtIndex:(NSInteger)index;
- (void)loopNodeAtIndex:(NSInteger)index;
@end

@protocol AudioEngineDelegate <NSObject>
- (void)nodeStatusChangedAtIndex:(NSInteger)index;
@optional
- (void)engineWasInterrupted;
- (void)engineConfigurationHasChanged;
- (void)mixerOutputFilePlayerHasStopped;
@end

@interface RYRiffAudioEngine : NSObject <RiffAudioDataSource>

- (nonnull instancetype)initWithRiffNodeCount:(NSInteger)riffNodeCount;

@property (nonatomic) float outputVolume;

@property (weak, nullable) id<AudioEngineDelegate> delegate;

@end