//
//  RYMediaEditor.m
//  Ryff
//
//  Created by Christopher Laganiere on 6/19/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYMediaEditor.h"

// Data Managers
#import "RYServices.h"

// Media Frameworks
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@implementation RYMediaEditor

static RYMediaEditor *_sharedInstance;
+ (instancetype)sharedInstance
{
    if (_sharedInstance == NULL)
    {
        _sharedInstance = [RYMediaEditor allocWithZone:NULL];
    }
    return _sharedInstance;
}

/*
 Helper function that gives NSURL to next available track path, incrementing name of track (track3.m4a, for example) until not taken.
 */
+ (NSURL*) pathForNextTrack
{
    NSURL *trackPath;
    
    NSString *documentDirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *trackDir        = [documentDirPath stringByAppendingPathComponent:@"UserTracks"];
    NSError *error            = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:trackDir isDirectory:nil])
        [[NSFileManager defaultManager] createDirectoryAtPath:trackDir withIntermediateDirectories:NO attributes:nil error:&error];
    
    NSInteger trackNum = 0;
    do {
        trackNum++;
        trackPath = [NSURL URLWithString:[trackDir stringByAppendingPathComponent:[NSString stringWithFormat:@"track%ld%@",(long)trackNum,kMediaFileType]]];
    } while ([[NSFileManager defaultManager] fileExistsAtPath:[trackPath path]]);
    return trackPath;
}

/*
 
 */
- (void) mergeAudioData:(NSArray*)trackURLs
{
    //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    
    for (NSURL *trackURL in trackURLs)
    {
        AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack setPreferredVolume:1.0];
        AVAsset *avAsset = [AVURLAsset URLAssetWithURL:trackURL options:nil];
        AVAssetTrack *clipAudioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset.duration) ofTrack:clipAudioTrack atTime:kCMTimeZero error:nil];
    }
    
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:composition
                                           presetName:AVAssetExportPresetAppleM4A];
    
    NSString *outputPath = [[RYServices urlForRiff] path];
    
    NSError *deleteError = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath])
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:&deleteError];
    
    // configure export session  output with all our parameters
    exportSession.outputURL = [NSURL fileURLWithPath:outputPath]; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    
    // perform the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            NSLog(@"AVAssetExportSessionStatusFailed");
        } else {
            NSLog(@"Export Session Status: %ld", (long)exportSession.status);
        }
    }];
}

@end
