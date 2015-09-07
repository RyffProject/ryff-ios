//
//  RYRiffAudioEngine.m
//  Ryff
//
//  Created by Christopher Laganiere on 12/22/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffAudioEngine.h"

@import AVFoundation;
@import Accelerate;

#import "RYRiffAudioNode.h"

static const CGFloat DefaultBPM = 120;
const NSString * __nonnull RecordingAudioFileFormat = @".caf";

#pragma mark - Riff Audio Engine

@interface RYRiffAudioEngine()

@property (nonatomic) AVAudioEngine *engine;
@property (nonatomic) NSTimer *beat;

@property (nonatomic) NSArray/*RYRiffAudioNode*/ *riffAudioNodes;
@property (nonatomic) NSURL *mixerOutputFileURL;
@property (nonatomic) BOOL isRecording;

@property (nonatomic, nullable) RYRiffAudioNode *recordingNode;

- (void)handleInterruption:(NSNotification *)notification;
- (void)handleRouteChange:(NSNotification *)notification;

@end

@implementation RYRiffAudioEngine

- (nonnull instancetype)initWithRiffNodeCount:(NSInteger)riffNodeCount
{
    if (self = [super init]) {
        
        _isRecording = NO;
        _mixerOutputFileURL = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"mixerOutput.caf"]];
        
//        [self startBeatTimer:(1/DefaultBPM)];
        
        [self createNodes:riffNodeCount];
        
        // create an instance of the engine and attach the nodes
        [self createEngineAndAttachNodes];
        
        // AVAudioSession setup
        [self initAVAudioSession];
        
        // make engine connections
        [self makeEngineConnections];
        
        // start the engine
        [self startEngine];
        
        // sign up for notifications from the engine if there's a hardware config change
        [[NSNotificationCenter defaultCenter] addObserverForName:AVAudioEngineConfigurationChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            
            // if we've received this notification, something has changed and the engine has been stopped
            // re-wire all the connections and start the engine
            NSLog(@"Received a %@ notification!", AVAudioEngineConfigurationChangeNotification);
            NSLog(@"Re-wiring connections and starting once again");
            [self makeEngineConnections];
            [self startEngine];
            
            // post notification
            if ([self.delegate respondsToSelector:@selector(engineConfigurationHasChanged)]) {
                [self.delegate engineConfigurationHasChanged];
            }
        }];
    }
    return self;
}

- (void)startBeatTimer:(NSTimeInterval)timeInterval {
    _beat = [NSTimer scheduledTimerWithTimeInterval:(1/DefaultBPM) target:self selector:@selector(beatStrike:) userInfo:nil repeats:YES];
    _beat.tolerance = 0.0001;
}

- (void)stopBeatTimer {
    [_beat invalidate];
}

- (void)beatStrike:(NSTimer *)beat {
    NSLog(@"beatStrike");
    
//    [self startWaitingAudioNodes];
}

- (void)startWaitingAudioNodes {
    for (RYRiffAudioNode *riffNode in self.riffAudioNodes) {
        if (riffNode.status == RYRiffAudioNodeStatusActive) {
            [riffNode play];
        }
    }
}

- (void)stopAllNodes {
    for (RYRiffAudioNode *riffNode in self.riffAudioNodes) {
        [riffNode stop];
    }
}

#pragma mark - Recording

- (void)startRecordingOutputToNode:(RYRiffAudioNode *)riffNode {
    if (!self.isRecording) {
        NSError *error;
        AVAudioMixerNode *mainMixer = [_engine mainMixerNode];
        AVAudioFile *mixerOutputFile = [[AVAudioFile alloc] initForWriting:_mixerOutputFileURL settings:[[mainMixer outputFormatForBus:0] settings] error:&error];
        if (error) {
            NSLog(@"stopRecording open file error: %@", [error localizedDescription]);
        }
        
        [self startEngine];
        [mainMixer installTapOnBus:0 bufferSize:4096 format:[mainMixer outputFormatForBus:0] block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when) {
            NSError *error;
            [mixerOutputFile writeFromBuffer:buffer error:&error];
            if (error) {
                NSLog(@"startRecordingOutputToNode tap error: %@", [error localizedDescription]);
            }
        }];
        _recordingNode = riffNode;
        _isRecording = YES;
    }
}

- (void)stopRecordingOutput {
    if (self.isRecording) {
        [[_engine mainMixerNode] removeTapOnBus:0];
        
        NSError *error;
        AVAudioFile *recordedFile = [[AVAudioFile alloc] initForReading:_mixerOutputFileURL error:&error];
        if (error) {
            NSLog(@"stopRecording open file error: %@", [error localizedDescription]);
        }
        
        [_recordingNode setAudioFile:recordedFile];
        [_recordingNode startWithDelay:0 looping:YES];
        [_recordingNode play];
        
        _recordingNode = nil;
        _isRecording = NO;
    }
}

#pragma mark - RiffAudioDataSource

- (nullable RYRiffAudioNode *)nodeAtIndex:(NSInteger)index {
    if (index >= 0 && index < self.riffAudioNodes.count) {
        return [self.riffAudioNodes objectAtIndex:index];
    }
    return nil;
}

- (void)toggleNodeAtIndex:(NSInteger)index {
    RYRiffAudioNode *riffNode = [self nodeAtIndex:index];
    if (riffNode) {
        switch (riffNode.status) {
            case RYRiffAudioNodeStatusEmpty:
                [self startRecordingOutputToNode:riffNode];
                riffNode.status = RYRiffAudioNodeStatusRecording;
                break;
            case RYRiffAudioNodeStatusRecording:
                [self stopRecordingOutput];
                riffNode.status = RYRiffAudioNodeStatusActive;
                break;
            case RYRiffAudioNodeStatusReadyToPlay:
                [riffNode play];
                riffNode.status = RYRiffAudioNodeStatusActive;
                break;
            case RYRiffAudioNodeStatusActive:
                [riffNode pause];
                riffNode.status = RYRiffAudioNodeStatusReadyToPlay;
                break;
        }
        
        [self.delegate nodeStatusChangedAtIndex:index];
    }
}

- (void)clearNodeAtIndex:(NSInteger)index {
    RYRiffAudioNode *riffNode = [self nodeAtIndex:index];
    if (riffNode) {
        [riffNode stop];
        [riffNode deleteAudio];
        riffNode.status = RYRiffAudioNodeStatusEmpty;
        
        [self.delegate nodeStatusChangedAtIndex:index];
    }
}

#pragma mark - Private

- (void)createEngineAndAttachNodes
{
    /*  An AVAudioEngine contains a group of connected AVAudioNodes ("nodes"), each of which performs
     an audio signal generation, processing, or input/output task.
     
     Nodes are created separately and attached to the engine.
     
     The engine supports dynamic connection, disconnection and removal of nodes while running,
     with only minor limitations:
     - all dynamic reconnections must occur upstream of a mixer
     - while removals of effects will normally result in the automatic connection of the adjacent
     nodes, removal of a node which has differing input vs. output channel counts, or which
     is a mixer, is likely to result in a broken graph. */
    
    _engine = [[AVAudioEngine alloc] init];
    
    /*  To support the instantiation of arbitrary AVAudioNode subclasses, instances are created
     externally to the engine, but are not usable until they are attached to the engine via
     the attachNode method. */
    
    for (RYRiffAudioNode *riffNode in self.riffAudioNodes) {
        [self.engine attachNode:riffNode.audioPlayerNode];
    }
}

- (void)createNodes:(NSInteger)nodeCount {
    NSMutableArray *riffAudioNodes = [[NSMutableArray alloc] initWithCapacity:nodeCount];
    for (NSInteger nodeIndex = 0; nodeIndex < nodeCount; nodeIndex++) {
        RYRiffAudioNode *riffNode = [[RYRiffAudioNode alloc] init];
        [riffAudioNodes addObject:riffNode];
    }
    self.riffAudioNodes = riffAudioNodes;
}

- (void)makeEngineConnections
{
    AVAudioMixerNode *mainMixer = [_engine mainMixerNode];
    
    for (RYRiffAudioNode *riffNode in self.riffAudioNodes) {
        [self.engine connect:riffNode.audioPlayerNode to:mainMixer format:[mainMixer outputFormatForBus:0]];
    }
    
    AVAudioInputNode *inputNode = [self.engine inputNode];
    [self.engine connect:inputNode to:[self.engine mainMixerNode] format:[inputNode inputFormatForBus:0]];
}

- (void)startEngine
{
    // start the engine
    
    /*  startAndReturnError: calls prepare if it has not already been called since stop.
     
     Starts the audio hardware via the AVAudioInputNode and/or AVAudioOutputNode instances in
     the engine. Audio begins flowing through the engine.
     
     This method will return YES for sucess.
     
     Reasons for potential failure include:
     
     1. There is problem in the structure of the graph. Input can't be routed to output or to a
     recording tap through converter type nodes.
     2. An AVAudioSession error.
     3. The driver failed to start the hardware. */
    
    if (!_engine.isRunning) {
        NSError *error;
        [_engine prepare];
        NSAssert([_engine startAndReturnError:&error], @"couldn't start engine, %@", [error localizedDescription]);
    }
}

#pragma mark AVAudioSession

- (void)initAVAudioSession
{
    // For complete details regarding the use of AVAudioSession see the AVAudioSession Programming Guide
    // https://developer.apple.com/library/ios/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/Introduction/Introduction.html
    
    // Configure the audio session
    AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
    NSError *error;
    
    // set the session category
    bool success = [sessionInstance setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!success) NSLog(@"Error setting AVAudioSession category! %@\n", [error localizedDescription]);
    
    double hwSampleRate = 44100.0;
    success = [sessionInstance setPreferredSampleRate:hwSampleRate error:&error];
    if (!success) NSLog(@"Error setting preferred sample rate! %@\n", [error localizedDescription]);
    
    NSTimeInterval ioBufferDuration = 0.0029;
    success = [sessionInstance setPreferredIOBufferDuration:ioBufferDuration error:&error];
    if (!success) NSLog(@"Error setting preferred io buffer duration! %@\n", [error localizedDescription]);
    
    // add interruption handler
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:sessionInstance];
    
    // we don't do anything special in the route change notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:sessionInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMediaServicesReset:)
                                                 name:AVAudioSessionMediaServicesWereResetNotification
                                               object:sessionInstance];
    
    // activate the audio session
    success = [sessionInstance setActive:YES error:&error];
    if (!success) NSLog(@"Error setting session active! %@\n", [error localizedDescription]);
}

- (void)handleInterruption:(NSNotification *)notification
{
    UInt8 theInterruptionType = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] intValue];
    
    NSLog(@"Session interrupted > --- %s ---\n", theInterruptionType == AVAudioSessionInterruptionTypeBegan ? "Begin Interruption" : "End Interruption");
    
    if (theInterruptionType == AVAudioSessionInterruptionTypeBegan) {
        [self stopRecordingOutput];
        [self stopAllNodes];
        
        if ([self.delegate respondsToSelector:@selector(engineWasInterrupted)]) {
            [self.delegate engineWasInterrupted];
        }
    }
    if (theInterruptionType == AVAudioSessionInterruptionTypeEnded) {
        // make sure to activate the session
        NSError *error;
        bool success = [[AVAudioSession sharedInstance] setActive:YES error:&error];
        if (!success) NSLog(@"AVAudioSession set active failed with error: %@", [error localizedDescription]);
        
        // start the engine once again
        [self startEngine];
    }
}

- (void)handleRouteChange:(NSNotification *)notification
{
    UInt8 reasonValue = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] intValue];
    AVAudioSessionRouteDescription *routeDescription = [notification.userInfo valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
    
    NSLog(@"Route change:");
    switch (reasonValue) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"     NewDeviceAvailable");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"     OldDeviceUnavailable");
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            NSLog(@"     CategoryChange");
            NSLog(@" New Category: %@", [[AVAudioSession sharedInstance] category]);
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            NSLog(@"     Override");
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            NSLog(@"     WakeFromSleep");
            break;
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            NSLog(@"     NoSuitableRouteForCategory");
            break;
        default:
            NSLog(@"     ReasonUnknown");
    }
    
    NSLog(@"Previous route:\n");
    NSLog(@"%@", routeDescription);
}

- (void)handleMediaServicesReset:(NSNotification *)notification
{
    // if we've received this notification, the media server has been reset
    // re-wire all the connections and start the engine
    NSLog(@"Media services have been reset!");
    NSLog(@"Re-wiring connections and starting once again");
    
    [self createEngineAndAttachNodes];
    [self initAVAudioSession];
    [self makeEngineConnections];
    [self startEngine];
    
    // post notification
    if ([self.delegate respondsToSelector:@selector(engineConfigurationHasChanged)]) {
        [self.delegate engineConfigurationHasChanged];
    }
}

@end
