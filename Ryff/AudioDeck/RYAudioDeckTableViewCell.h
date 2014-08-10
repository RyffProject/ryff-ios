//
//  RYAudioDeckTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 8/10/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYNewsfeedPost;

@interface RYAudioDeckTableViewCell : UITableViewCell

- (void) configureForRif:(RYNewsfeedPost *)post trackIdx:(NSInteger)trackIdx;
- (void) stylePlaying:(BOOL)playing;
- (void) updateDownloadProgress:(CGFloat)progress;

@end