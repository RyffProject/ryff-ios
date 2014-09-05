//
//  RYDataManager.m
//  Ryff
//
//  Created by Christopher Laganiere on 7/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYDataManager.h"

// Data Managers
#import "RYMediaEditor.h"
#import "RYAudioDeckManager.h"

// Data Objects
#import "RYRiff.h"

// Frameworks
#import "AFHTTPRequestOperation.h"

#define kRiffDirectory @"http://ryff.me/riffs/"

@implementation DownloadOperation

- (id) initWithOperation:(AFHTTPRequestOperation *)operation localURL:(NSURL *)localURL
{
    if (self = [super init])
    {
        _operation = operation;
        _localURL  = localURL;
    }
    return self;
}

+ (DownloadOperation *)downloadOperation:(AFHTTPRequestOperation *)operation localURL:(NSURL *)localURL
{
    return [[DownloadOperation alloc] initWithOperation:operation localURL:localURL];
}

@end

@interface RYDataManager ()

// NSDictionaries of format @{@"operation": [AFHTTPRequestOperation], @"url": [localURL]}
@property (nonatomic, strong) NSMutableArray *downloadQueue;
@property (nonatomic, strong) DownloadOperation *currentDownload;

@end

@implementation RYDataManager

static RYDataManager *_sharedInstance;
+ (instancetype)sharedInstance
{
    if (_sharedInstance == NULL)
    {
        _sharedInstance = [RYDataManager allocWithZone:NULL];
        _sharedInstance.downloadQueue = [[NSMutableArray alloc] init];
    }
    return _sharedInstance;
}

+ (NSURL *)urlForRiff
{
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"riff.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    return outputFileURL;
}

+ (NSURL *)urlForTempRiff:(NSString *)fileName
{
    NSString *documentDirPath = NSTemporaryDirectory();
    NSString *trackDir        = [documentDirPath stringByAppendingPathComponent:@"Riffs"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:trackDir isDirectory:nil])
        [[NSFileManager defaultManager] createDirectoryAtPath:trackDir withIntermediateDirectories:NO attributes:nil error:NULL];
    
    return [NSURL URLWithString:[trackDir stringByAppendingPathComponent:fileName]];
}

/*
 Helper function that gives NSURL to next available track path, incrementing name of track (track3.m4a, for example) until not taken.
 */
+ (NSURL *)urlForNextTrack
{
    NSURL *trackPath;
    
    NSString *documentDirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *trackDir        = [documentDirPath stringByAppendingPathComponent:@"UserTracks"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:trackDir isDirectory:nil])
        [[NSFileManager defaultManager] createDirectoryAtPath:trackDir withIntermediateDirectories:NO attributes:nil error:NULL];
    
    NSInteger trackNum = 0;
    do {
        trackNum++;
        NSString *trackString = [[trackDir stringByAppendingPathComponent:[NSString stringWithFormat:@"track%ld%@",(long)trackNum,kMediaFileType]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
        trackPath = [NSURL fileURLWithPath:trackString];
    } while ([[NSFileManager defaultManager] fileExistsAtPath:[trackPath path]]);
    return trackPath;
}

- (void) fetchTempRiff:(RYRiff *)riff forDelegate:(id<TrackDownloadDelegate>)delegate
{
    NSURL *localURL = [RYDataManager urlForTempRiff:riff.fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[localURL path]])
    {
        // don't need to download
        if (delegate && [delegate respondsToSelector:@selector(track:FinishedDownloading:)])
            [delegate track:riff.URL FinishedDownloading:localURL];
    }
    else
    {
        // start download
        [self saveRiffAt:riff.URL toLocalURL:localURL forDelegate:delegate];
    }
}

/*
 Helper method to save a remote riff file to the device, as a track for use in creating a new riff or for riff details
 */
- (void) saveRiffAt:(NSURL*)riffURL toLocalURL:(NSURL *)localURL forDelegate:(id<TrackDownloadDelegate>)delegate
{
    NSURLRequest *request = [NSURLRequest requestWithURL:riffURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[localURL path] append:NO];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (delegate && [delegate respondsToSelector:@selector(track:DownloadProgressed:)])
        {
            CGFloat downloadProgress = totalBytesRead / (CGFloat)totalBytesExpectedToRead;
            [delegate track:riffURL DownloadProgressed:downloadProgress];
        }
    }];
    
    DownloadOperation *downloadOperation = [DownloadOperation downloadOperation:operation localURL:localURL];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_downloadQueue removeObject:operation];
        
        if (delegate && [delegate respondsToSelector:@selector(track:FinishedDownloading:)])
            [delegate track:riffURL FinishedDownloading:localURL];
        
        [_downloadQueue removeObject:downloadOperation];
        _currentDownload = nil;
        [self startNextDownload];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_downloadQueue removeObject:downloadOperation];
        if (delegate && [delegate respondsToSelector:@selector(track:DownloadFailed:)])
            [delegate track:riffURL DownloadFailed:[error localizedDescription]];
        
        [_downloadQueue removeObject:downloadOperation];
        _currentDownload = nil;
        [self startNextDownload];
    }];
    [_downloadQueue addObject:downloadOperation];
    [self startNextDownload];
}

- (void) cancelDownloadOperationWithURL:(NSURL *)url
{
    for (DownloadOperation *download in _downloadQueue)
    {
        if (download.operation.request.URL == url)
        {
            [download.operation cancel];
            [_downloadQueue removeObject:download];
            if (_currentDownload == download)
                _currentDownload = nil;
            
            NSURL *localURL = download.localURL;
            [[NSFileManager defaultManager] removeItemAtPath:localURL.path error:NULL];
            
            [self startNextDownload];
            break;
        }
    }
}

#pragma mark - Internal

- (void) startNextDownload
{
    if (!_currentDownload && _downloadQueue.count > 0)
    {
        DownloadOperation *next = _downloadQueue[0];
        [next.operation start];
    }
}

#pragma mark -
#pragma mark - Riff Caching

/**
 *  Clear cache, saving files which are currently in the AudioDeck playlist
 */
- (void) clearCache
{
    NSString *directory = NSTemporaryDirectory();
    NSError *error = nil;
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error])
    {
        if (![[RYAudioDeckManager sharedInstance] playlistContainsFile:file])
        {
            [[NSFileManager defaultManager] removeItemAtPath:[directory stringByAppendingPathComponent:file] error:&error];
            if (error)
                NSLog(@"clearCache failed: %@",[error localizedDescription]);
        }
    }
    
    for (DownloadOperation *download in _downloadQueue)
    {
        [download.operation cancel];
    }
    [_downloadQueue removeAllObjects];
}

@end
