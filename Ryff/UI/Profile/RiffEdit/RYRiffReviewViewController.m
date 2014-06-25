//
//  RYRiffReviewViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/13/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffReviewViewController.h"

// Data Managers
#import "RYServices.h"

// Data Objects
#import "RYRiff.h"

// Associated View Controllers
#import "RYProfileViewController.h"

// Custom UI
#import "RYStyleSheet.h"

// Categories
#import "UIImage+Color.h"
#import "UIViewController+Extras.h"

// Media
#import <AVFoundation/AVFoundation.h>

@interface RYRiffReviewViewController () <AVAudioPlayerDelegate, UITextViewDelegate, RiffDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *riffTitleTextField;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *durationTextLabel;

// Data
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, strong) RYRiff *riff;
@property (nonatomic, strong) NSTimer *updateTimer;
@end

@implementation RYRiffReviewViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepAudio];
    
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshUI:) userInfo:nil repeats:YES];
    
    [self startUI];
}

- (void) configureWithRiff:(RYRiff *)riff
{
    _riff = riff;
    
    [_descriptionTextView setText:@"Riff Description"];
}

#pragma mark -
#pragma mark - UI

- (void) startUI
{
    [_descriptionTextView setDelegate:self];
    [_descriptionTextView setText:@"Description"];
    
    // Design
    [_progressSlider setValue:0];
    
    [_playButton setTitle:@"" forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_playButton setTintColor:[RYStyleSheet baseColor]];
    
    [_cancelButton setImage:[[UIImage imageNamed:@"back"] imageWithOverlayColor:[RYStyleSheet baseColor]]];
    [_saveButton setImage:[[UIImage imageNamed:@"cloud"] imageWithOverlayColor:[RYStyleSheet baseColor]]];
    
    [_progressSlider setTintColor:[RYStyleSheet baseColor]];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelHit:)];
    [cancel setImage:[UIImage imageNamed:@"back"]];
    [cancel setTintColor:[RYStyleSheet baseColor]];
    [cancel setAction:@selector(cancelHit:)];
    [self.navigationItem setLeftBarButtonItem:cancel];
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(saveHit:)];
    [save setImage:[UIImage imageNamed:@"cloud"]];
    [save setTintColor:[RYStyleSheet baseColor]];
    [save setAction:@selector(saveHit:)];
    [self.navigationItem setRightBarButtonItem:save];
}

- (void) refreshUI:(NSTimer*)timer
{
    //progress bar
    CGFloat progress = (_player.currentTime / _player.duration);
    [_progressSlider setValue:progress];
    
    //length text
    if (_player.playing)
    {
        NSInteger seconds = (NSInteger)_player.currentTime % 60;
        NSInteger minutes = (NSInteger)_player.currentTime / 60;
        [_durationTextLabel setText:[NSString stringWithFormat:@"%02ld:%02ld",(long)minutes,(long)seconds]];
    }
    else
    {
        NSInteger seconds = (NSInteger)_player.duration % 60;
        NSInteger minutes = (NSInteger)_player.duration / 60;
        [_durationTextLabel setText:[NSString stringWithFormat:@"%02ld:%02ld",(long)minutes,(long)seconds]];
        [self stylePlayButton:NO];
    }
}

#pragma mark -
#pragma mark - Media

- (void) prepAudio
{
    NSURL *pathAsURL = [RYServices urlForRiff];
    
    // Init the audio player.
    NSError *error;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:pathAsURL error:&error];
    
    NSInteger seconds = (NSInteger)_player.duration % 60;
    NSInteger minutes = (NSInteger)_player.duration / 60;
    [_durationTextLabel setText:[NSString stringWithFormat:@"%02ld:%02ld",(long)minutes,(long)seconds]];
    
    // Check out what's wrong in case that the player doesn't init.
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    else
    {
        [_player prepareToPlay];
    }
    
    [_player setDelegate:self];
}

- (BOOL) readyForSubmission
{
    if (_riffTitleTextField.text.length == 0)
        return NO;
    return YES;
}

- (void) processRiff
{
    [self showHUDWithTitle:@"Uploading"];
    [[RYServices sharedInstance] postRiffWithContent:_descriptionTextView.text title:_riffTitleTextField.text duration:[NSNumber numberWithFloat:_player.duration] ForDelegate:self];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)playPauseHit:(id)sender
{
    if (_player.playing)
    {
        [_player pause];
        [self stylePlayButton:NO];
    }
    else
    {
        [_player play];
        [self stylePlayButton:YES];
    }
}

- (IBAction)progressSliderChanged:(id)sender
{
    CGFloat newTime = ((UISlider*)sender).value*_player.duration;
    [_player setCurrentTime:newTime];
}

- (IBAction)cancelHit:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveHit:(id)sender
{
    if ([self readyForSubmission])
    {
        [self processRiff];
    }
}

#pragma mark -
#pragma mark - UI

- (void)stylePlayButton:(BOOL)playing
{
    if (playing)
    {
        // prepare loading images
        NSInteger numImages = 3;
        NSMutableArray *images = [[NSMutableArray alloc] init];
        
        // load all rotations of these images
        for (NSNumber *rotation in @[@0,@2,@1,@3])
        {
            for (NSInteger imNum = 1; imNum <= numImages; imNum++)
            {
                NSInteger rotateVar = [rotation integerValue];
                UIImage *loadingImage = [[UIImage imageNamed:[NSString stringWithFormat:@"Loading_%ld",(long)imNum]] imageWithOverlayColor:[RYStyleSheet baseColor]];
                loadingImage = [RYStyleSheet image:loadingImage RotatedByRadians:M_PI_2*rotateVar];
                [images addObject:loadingImage];
            }
        }
        
        // Normal Animation
        _playButton.imageView.animationImages = images;
        _playButton.imageView.animationDuration = 1.5;
        
        [_playButton.imageView startAnimating];
    }
    else
    {
        [_playButton setImage:[[UIImage imageNamed:@"play"] imageWithOverlayColor:[RYStyleSheet baseColor]] forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark - RiffDelegate

- (void) riffPostSucceeded
{
    [self hideHUD];
    [self showCheckHUDWithTitle:@"Posted" forDuration:1.5f];
}

- (void) riffPostFailed
{
    [self hideHUD];
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error Uploading" message:@"Something went wrong uploading, try again later." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [errorAlert show];
}

@end
