//
//  RYRiffDetailsTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 7/30/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYNewsfeedPost;
@class RYUser;

@protocol RiffDetailsDelegate <NSObject>
- (void) riffAvatarTapAction:(NSInteger)postIdx;
@end

@interface RYRiffDetailsTableViewCell : UITableViewCell

- (void) configureWithPost:(RYNewsfeedPost *)post postIdx:(NSInteger)postIdx actionString:(NSString *)actionString delegate:(id<RiffDetailsDelegate>)delegate;
- (void) configureWithAttributedString:(NSAttributedString *)attString imageURL:(NSURL *)url;

@property (nonatomic, weak) id<RiffDetailsDelegate> delegate;
@property (nonatomic, assign) NSInteger postIdx;

@end
