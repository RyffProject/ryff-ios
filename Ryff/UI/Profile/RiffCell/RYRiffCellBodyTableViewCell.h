//
//  RYRiffCellBodyTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 5/24/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRiffBodyCellPadding 20.0f

@interface RYRiffCellBodyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *wrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *riffTextLabel;

- (void) configureWithAttributedString:(NSAttributedString*)attributedString;

@end
