//
//  RYLoginTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 6/28/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RYLoginTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *loginLabel;

- (void) configureWithTitle:(NSString*)title;

@end
