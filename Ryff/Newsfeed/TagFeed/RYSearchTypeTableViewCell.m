//
//  RYSearchTypeTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/1/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYSearchTypeTableViewCell.h"

// Data Managers
#import "RYStyleSheet.h"

@interface RYSearchTypeTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *wrapperView;
@property (weak, nonatomic) IBOutlet UIButton *typeTrendingButton;
@property (weak, nonatomic) IBOutlet UIButton *typeNewButton;
@property (weak, nonatomic) IBOutlet UIButton *typeTopButton;

// Data
@property (nonatomic, weak) id<SearchTypeDelegate> delegate;

@end

@implementation RYSearchTypeTableViewCell

- (void) configureWithSearchType:(SearchType)searchType delegate:(id<SearchTypeDelegate>)delegate
{
    _delegate = delegate;
    [_typeTrendingButton.titleLabel setFont:[UIFont fontWithName:kRegularFont size:16.0f]];
    [_typeNewButton.titleLabel setFont:[UIFont fontWithName:kRegularFont size:16.0f]];
    [_typeTopButton.titleLabel setFont:[UIFont fontWithName:kRegularFont size:16.0f]];
    [_typeTrendingButton setTintColor:[RYStyleSheet availableActionColor]];
    [_typeNewButton setTintColor:[RYStyleSheet availableActionColor]];
    [_typeTopButton setTintColor:[RYStyleSheet availableActionColor]];
    
    // highlight selected
    switch (searchType) {
        case TRENDING:
            [_typeTrendingButton setTintColor:[RYStyleSheet postActionColor]];
            break;
        case NEW:
            [_typeNewButton setTintColor:[RYStyleSheet postActionColor]];
            break;
        case TOP:
            [_typeTopButton setTintColor:[RYStyleSheet postActionColor]];
            break;
    }
    
    [self setBackgroundColor:nil];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)typeTrendingButtonHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(searchTypeChosen:)])
        [_delegate searchTypeChosen:TRENDING];
}

- (IBAction)typeNewButtonHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(searchTypeChosen:)])
        [_delegate searchTypeChosen:NEW];
}

- (IBAction)typeTopButtonHit:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(searchTypeChosen:)])
        [_delegate searchTypeChosen:TOP];
}

@end
