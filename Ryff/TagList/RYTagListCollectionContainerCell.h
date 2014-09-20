//
//  RYTagListCollectionContainerCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYTag;

@protocol TagListCollectionContainerDelegate <NSObject>
- (void) tagSelected:(RYTag *)tag;
@end

@class RYTagList;

@interface RYTagListCollectionContainerCell : UICollectionViewCell

@property (nonatomic, weak) id<TagListCollectionContainerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void) configureWithTagList:(RYTagList *)tagList delegate:(id<TagListCollectionContainerDelegate>)delegate;

@end
