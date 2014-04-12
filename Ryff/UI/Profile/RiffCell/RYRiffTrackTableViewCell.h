//
//  RYRiffTrackTableViewCell.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RYRiffTrackTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *riffTitleText;
@property (weak, nonatomic) IBOutlet UILabel *riffLengthText;

@end
