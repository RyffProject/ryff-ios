//
//  RYDataManager.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RYRiff;

@protocol TrackDownloadDelegate <NSObject>
- (void) track:(NSURL*)trackURL DownloadProgressed:(CGFloat)progress;
- (void) track:(NSURL*)trackURL FinishedDownloading:(NSURL*)localURL;
@optional
- (void) track:(NSURL*)trackURL DownloadFailed:(NSString*)reason;
@end

@interface RYDataManager : NSObject

+ (instancetype) sharedInstance;

+ (NSURL *)urlForRiff;
+ (NSURL *)urlForTempRiff:(NSString *)fileName;
+ (NSURL *)urlForNextTrack;

- (void) fetchTempRiff:(RYRiff *)riff forDelegate:(id<TrackDownloadDelegate>)delegate;
- (void) saveRiffAt:(NSURL*)riffURL toLocalURL:(NSURL *)localURL forDelegate:(id<TrackDownloadDelegate>)delegate;
- (void) getRiffFile:(NSString *)fileName completion:(void(^)(BOOL success, NSString *localPath))completion;

@end
