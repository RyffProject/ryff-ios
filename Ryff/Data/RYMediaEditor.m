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
#import "RYDataManager.h"

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
 Merges audio tracks into one file, and notifies _mergeDelegate of success/failure
 PARAMETERS:
 -trackURLS: NSArray of urls for component tracks to merge.
 RETURNS: NSURL for new audio file.
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
    
    NSString *outputPath = [[RYDataManager urlForRiff] path];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath])
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:NULL];
    
    // configure export session  output with all our parameters
    exportSession.outputURL = [NSURL fileURLWithPath:outputPath]; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    
    // perform the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            if (_mergeDelegate && [_mergeDelegate respondsToSelector:@selector(mergeSucceeded:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_mergeDelegate mergeSucceeded:[RYDataManager urlForRiff]];
                });
            }
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            if (_mergeDelegate && [_mergeDelegate respondsToSelector:@selector(mergeFailed:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_mergeDelegate mergeFailed:[NSString stringWithFormat:@"Audio export failed: %@",[exportSession.error localizedDescription]]];
                });
            }
        } else {
            if (_mergeDelegate && [_mergeDelegate respondsToSelector:@selector(mergeFailed:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_mergeDelegate mergeFailed:[NSString stringWithFormat:@"Could not export, exportSessionStatus: %ld",(long)exportSession.status]];
                });
            }
        }
    }];
}

@end
