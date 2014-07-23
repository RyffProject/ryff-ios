//
//  RYRyRiffDetailsTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 5/25/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RyRiffDetailsTableViewCell.h"

// Data Managers
#import "RYServices.h"

// Data Objects
#import "RYNewsfeedPost.h"
#import "RYUser.h"

// Custom UI
#import "RYStyleSheet.h"

@interface RyRiffDetailsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *wrapperView;
@property (weak, nonatomic) IBOutlet UIButton *upvoteButton;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

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
    [_deleteButton setTintColor:[RYStyleSheet actionColor]];
}

- (void) configureForPost:(RYNewsfeedPost*)post index:(NSInteger)riffIndex withDelegate:(id<RYRiffDetailsCellDelegate>)delegate
{
    [self setBackgroundColor:[UIColor clearColor]];
    _delegate  = delegate;
    _riffIndex = riffIndex;
    
    if (![post.user.username isEqualToString:[RYServices loggedInUser].username])
        [_deleteButton setHidden:YES];
    
    if (post.isUpvoted)
        [_upvoteButton setTintColor:[RYStyleSheet actionHighlightedColor]];
    else
        [_upvoteButton setTintColor:[RYStyleSheet actionColor]];
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

- (IBAction)deleteHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteHit:)])
        [_delegate deleteHit:_riffIndex];
}

@end
