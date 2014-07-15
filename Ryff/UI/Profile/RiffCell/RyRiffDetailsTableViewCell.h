//
//  RYRyRiffDetailsTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 5/25/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYNewsfeedPost;

@protocol RYRiffDetailsCellDelegate <NSObject>

- (void) upvoteHit:(NSInteger)riffIndex;
- (void) repostHit:(NSInteger)riffIndex;
- (void) deleteHit:(NSInteger)riffIndex;

@end

@interface RyRiffDetailsTableViewCell : UITableViewCell

- (void) configureForPost:(RYNewsfeedPost*)post Index:(NSInteger)riffIndex WithDelegate:(id<RYRiffDetailsCellDelegate>)delegate;

@end
