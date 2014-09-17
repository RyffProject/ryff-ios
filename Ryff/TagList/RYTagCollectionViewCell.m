//
//  RYTagCollectionViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYTagCollectionViewCell.h"

// Data Objects
#import "RYTag.h"
#import "RYPost.h"

// Categories
#import "UIImageView+WebCache.h"

@interface RYTagCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *darkenView;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

// Data
@property (nonatomic, strong) RYTag *currentTag;

@end

@implementation RYTagCollectionViewCell

- (void) configureWithTag:(RYTag *)tag
{
    _currentTag = tag;
    
    // set image
    if (tag.trendingPost && tag.trendingPost.imageURL)
    {
        _tagLabel.layer.shadowOpacity = 0.7f;
        _darkenView.alpha = 0.45f;
        [_imageView sd_setImageWithURL:tag.trendingPost.imageURL];
    }
    else
    {
        _tagLabel.layer.shadowOpacity = 0.0f;
        _darkenView.alpha = 0.6f;
        [tag retrieveTrendingPostWithImage];
    }
    
    _tagLabel.text = tag.tag;
    _descriptionLabel.text = [NSString stringWithFormat:@"%ld Posts",(long)tag.numPosts];
    
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark -
#pragma mark - LifeCycle

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    _tagLabel.font = [UIFont fontWithName:kBoldFont size:21.0f];
    _tagLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _tagLabel.layer.shadowOffset = CGSizeMake(-1, 1);
    _tagLabel.layer.shadowRadius = 2.0f;
    
    self.layer.cornerRadius = 35.0f;
    self.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagUpdated:) name:kRetrievedTrendingPostNotification object:nil];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    
    _imageView.image = nil;
}

#pragma mark - Notifications

- (void) tagUpdated:(NSNotification *)notification
{
    if (notification.userInfo[@"tag"] && [notification.userInfo[@"tag"] isEqualToString:_currentTag.tag])
        [self configureWithTag:_currentTag];
}

@end
