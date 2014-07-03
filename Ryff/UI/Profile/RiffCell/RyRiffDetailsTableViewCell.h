//
//  RYRyRiffDetailsTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 5/25/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RYRiffDetailsCellDelegate <NSObject>

- (void) upvoteHit:(NSInteger)riffIndex;
- (void) repostHit:(NSInteger)riffIndex;

@end

@interface RyRiffDetailsTableViewCell : UITableViewCell

- (void) configureForIndex:(NSInteger)riffIndex WithDelegate:(id<RYRiffDetailsCellDelegate>)delegate;

@end
