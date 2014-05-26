//
//  RYRyRiffDetailsTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 5/25/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RyRiffDetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *wrapperView;

- (void) configure;

@end
