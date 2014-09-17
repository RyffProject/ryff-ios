//
//  RYPostImageTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/6/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYPostImageTableViewCell.h"

// Data Managers
#import "RYStyleSheet.h"

// Categories
#import "UIImageView+WebCache.h"
#import "UIImage+Color.h"

@interface RYPostImageTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *centerImageView;

@property (weak, nonatomic) IBOutlet UIView *parentsWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *parentsImageView;
@property (weak, nonatomic) IBOutlet UILabel *parentsCountLabel;

@end

@implementation RYPostImageTableViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    _parentsCountLabel.font = [UIFont fontWithName:kRegularFont size:18.0f];
    _parentsCountLabel.textColor = [RYStyleSheet availableActionColor];
    
    UITapGestureRecognizer *parentsWrapperTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(parentsWrapperViewHit:)];
    [_parentsWrapperView addGestureRecognizer:parentsWrapperTap];
    
    UITapGestureRecognizer *centerImageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(centerImageHit:)];
    [_centerImageView addGestureRecognizer:centerImageViewTap];
}

- (void) configureWithImageURL:(NSURL *)imageURL numParents:(NSInteger)numParents delegate:(id<PostImageCellDelegate>)delegate
{
    _delegate = delegate;
    
    [_centerImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"user"]];
    
    if (numParents > 0)
    {
        _parentsWrapperView.hidden = NO;
        [_parentsImageView setImage:[[UIImage imageNamed:@"remix"] colorImage:[RYStyleSheet availableActionColor]]];
        [_parentsCountLabel setText:[NSString stringWithFormat:@"%ld",(long)numParents]];
    }
    else
        _parentsWrapperView.hidden = YES;
    
    [self setBackgroundColor:[UIColor clearColor]];
}

#pragma mark -
#pragma mark - Actions

- (void) parentsWrapperViewHit:(UITapGestureRecognizer *)tapGesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(parentsTapped)])
        [_delegate parentsTapped];
}

- (void) centerImageHit:(UITapGestureRecognizer *)tapGesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(postImageTapped)])
        [_delegate postImageTapped];
}

@end
