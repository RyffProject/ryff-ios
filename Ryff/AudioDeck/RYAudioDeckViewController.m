//
//  RYAudioDeckViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 8/10/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYAudioDeckViewController.h"

// Data Managers
#import "RYAudioDeckManager.h"

// Custom UI
#import "RYAudioDeckTableViewCell.h"

#define kAudioDeckCellReuseID @"audioDeckCell"

@interface RYAudioDeckViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *controlWrapperView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *nowPlayingLabel;
@property (weak, nonatomic) IBOutlet UISlider *playbackSlider;

@end

@implementation RYAudioDeckViewController

#pragma mark -
#pragma mark - Actions

- (IBAction)playButtonHit:(id)sender
{
    
}

- (IBAction)repostButtonHit:(id)sender
{
    
}

- (IBAction)nextButtonHit:(id)sender
{
    
}

- (IBAction)volumeSliderChanged:(id)sender
{
    
}

- (IBAction)playbackSliderChanged:(id)sender
{
    
}

#pragma mark -
#pragma mark - TableView Data Source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - TableView Delegate

@end
