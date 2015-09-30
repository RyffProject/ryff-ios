//
//  RYLoadMoreControl.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/23/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RYLoadMoreControl : UIControl

@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, strong) UIColor *tintColor;

- (id) initInScrollView:(UIScrollView *)scrollView;

- (void) beginLoading;
- (void) endLoading;

@end
