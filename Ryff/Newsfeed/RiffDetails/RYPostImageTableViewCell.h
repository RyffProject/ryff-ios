//
//  RYPostImageTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/6/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostImageCellDelegate <NSObject>
- (void) postImageTapped;
- (void) parentsTapped;
@end

@interface RYPostImageTableViewCell : UITableViewCell

@property (nonatomic, weak) id<PostImageCellDelegate>delegate;

- (void) configureWithImageURL:(NSURL *)imageURL numParents:(NSInteger)numParents delegate:(id<PostImageCellDelegate>)delegate;

@end
