//
//  RYSearchTypeTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/1/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RYServices.h"

#define kSearchTypeCellHeight 40.0f

@protocol SearchTypeDelegate <NSObject>
- (void) searchTypeChosen:(SearchType)searchType;
@end

@interface RYSearchTypeTableViewCell : UITableViewCell

- (void) configureWithSearchType:(SearchType)searchType delegate:(id<SearchTypeDelegate>)delegate;

@end
