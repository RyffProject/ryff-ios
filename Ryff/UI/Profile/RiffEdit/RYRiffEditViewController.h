//
//  RYRiffEditViewController.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/13/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYCoreViewController.h"

@class RYRiff;

@interface RYRiffEditViewController : RYCoreViewController

- (void) configureWithRiff:(RYRiff *)riff;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *riffTitleTextField;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *durationTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *restartButton;

- (IBAction)restart:(id)sender;
- (IBAction)playPauseHit:(id)sender;
- (IBAction)cancelHit:(id)sender;
- (IBAction)saveHit:(id)sender;
@end
