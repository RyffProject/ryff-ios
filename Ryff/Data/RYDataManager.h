//
//  RYDataManager.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TrackDownloadDelegate <NSObject>
- (void) track:(NSURL*)trackURL DownloadProgressed:(CGFloat)rogress;
- (void) track:(NSURL*)trackURL FinishedDownloading:(NSURL*)localURL;
- (void) track:(NSURL*)trackURL DownloadFailed:(NSString*)reason;
@end

@interface RYDataManager : NSObject

+ (instancetype) sharedInstance;

+ (NSURL*) urlForNextTrack;

- (void) saveRiffAt:(NSURL*)riffURL forDelegate:(id<TrackDownloadDelegate>)delegate;
- (void) getRiffFile:(NSString *)fileName completion:(void(^)(BOOL success))callback;

@end
