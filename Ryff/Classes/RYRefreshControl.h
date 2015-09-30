//
//  RYRefreshControl.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/7/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RYRefreshControl : UIControl

@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, strong) UIColor *tintColor;

- (id) initInScrollView:(UIScrollView *)scrollView;

- (void) beginRefreshing;
- (void) endRefreshing;

@end
