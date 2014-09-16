//
//  RYTagListCollectionTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYTag;

@protocol TagListCollectionDelegate <NSObject>
- (void) tagSelected:(RYTag *)tag;
@end

@class RYTagList;

@interface RYTagListCollectionTableViewCell : UITableViewCell

@property (nonatomic, weak) id<TagListCollectionDelegate> delegate;

- (void) configureWithTagList:(RYTagList *)tagList delegate:(id<TagListCollectionDelegate>)delegate;

@end
