//
//  RYPostImageTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/6/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYPostImageTableViewCell.h"

// Categories
#import "UIImageView+SGImageCache.h"

@interface RYPostImageTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *centerImageView;

@end

@implementation RYPostImageTableViewCell

- (void) configureWithImageURL:(NSString *)urlString delegate:(id<PostImageCellDelegate>)delegate
{
    _delegate = delegate;
}

@end
