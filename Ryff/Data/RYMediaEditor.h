//
//  RYMediaEditor.h
//  Ryff
//
//  Created by Christopher Laganiere on 6/19/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMediaFileType @".m4a"

@protocol MergeAudioDelegate <NSObject>
- (void) mergeSucceeded:(NSURL*)newTrackURL;
- (void) mergeFailed:(NSString*)reason;
@end

@interface RYMediaEditor : NSObject

@property (nonatomic, weak) id<MergeAudioDelegate> mergeDelegate;

+ (instancetype) sharedInstance;

- (void) mergeAudioData:(NSArray*)trackURLs;

@end
