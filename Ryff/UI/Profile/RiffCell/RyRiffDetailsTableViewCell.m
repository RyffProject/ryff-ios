//
//  RYRyRiffDetailsTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 5/25/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RyRiffDetailsTableViewCell.h"

// Custom UI
#import "RYStyleSheet.h"

@interface RyRiffDetailsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *wrapperView;
@property (weak, nonatomic) IBOutlet UIButton *upvoteButton;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;

// Data
@property (nonatomic, weak) id<RYRiffDetailsCellDelegate> delegate;
@property (nonatomic, assign) NSInteger riffIndex;

@end

@implementation RyRiffDetailsTableViewCell

- (void) awakeFromNib
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [_upvoteButton setTintColor:[RYStyleSheet actionColor]];
    [_repostButton setTintColor:[RYStyleSheet actionColor]];
}

- (void) configureForIndex:(NSInteger)riffIndex WithDelegate:(id<RYRiffDetailsCellDelegate>)delegate
{
    [self setBackgroundColor:[UIColor clearColor]];
    _delegate  = delegate;
    _riffIndex = riffIndex;
}

#pragma mark -
#pragma mark - Actions

- (IBAction)upvoteHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(upvoteHit:)])
        [_delegate upvoteHit:_riffIndex];
}

- (IBAction)repostHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(repostHit:)])
        [_delegate repostHit:_riffIndex];
}

@end
