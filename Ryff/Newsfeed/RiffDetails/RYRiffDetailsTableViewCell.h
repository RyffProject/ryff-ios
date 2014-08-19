//
//  RYRiffDetailsTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/30/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYNewsfeedPost;

@protocol RiffDetailsDelegate <NSObject>
- (void) riffAvatarTapAction;
@end

@interface RYRiffDetailsTableViewCell : UITableViewCell

- (void) configureWithPost:(RYNewsfeedPost *)post actionString:(NSString *)actionString delegate:(id<RiffDetailsDelegate>)delegate;

@property (nonatomic, weak) id<RiffDetailsDelegate> delegate;

@end
