//
//  RYDataManager.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

@import Foundation;

@class AFHTTPRequestOperation;

@protocol TrackDownloadDelegate <NSObject>
- (void) track:(NSURL*)trackURL downloadProgressed:(CGFloat)progress;
- (void) track:(NSURL*)trackURL finishedDownloading:(NSURL*)localURL;
@optional
- (void) track:(NSURL*)trackURL downloadFailed:(NSString*)reason;
@end

@interface DownloadOperation : NSObject
@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@property (nonatomic, strong) NSURL *localURL;
- (id) initWithOperation:(AFHTTPRequestOperation *)operation localURL:(NSURL *)localURL;
+ (DownloadOperation *)downloadOperation:(AFHTTPRequestOperation *)operation localURL:(NSURL *)localURL;
@end

@interface RYDataManager : NSObject

+ (instancetype) sharedInstance;

+ (NSURL *)urlForRiff;
+ (NSURL *)urlForTempRiff:(NSURL *)riffURL;
+ (NSURL *)urlForNextTrack;

- (void) fetchTempRiff:(NSURL *)riffURL forDelegate:(id<TrackDownloadDelegate>)delegate;
- (void) saveRiffAt:(NSURL*)riffURL toLocalURL:(NSURL *)localURL forDelegate:(id<TrackDownloadDelegate>)delegate;
- (void) deleteLocalRiff:(NSURL *)riffURL;

- (void) cancelDownloadOperationWithURL:(NSURL *)url;
- (void) clearCache;

@end
