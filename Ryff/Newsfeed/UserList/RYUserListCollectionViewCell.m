//
//  RYUserListCollectionViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/19/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYUserListCollectionViewCell.h"

// Data Objects
#import "RYUser.h"

// Custom UI
#import "DWTagList.h"

@interface RYUserListCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *avatarWrapperView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UIView *detailsWrapperView;
@property (weak, nonatomic) IBOutlet UIView *upvotesContainerView;
@property (weak, nonatomic) IBOutlet UILabel *upvoteCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *upvoteImageView;
@property (weak, nonatomic) IBOutlet UIView *followersContainerView;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *followersImageView;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet DWTagList *tagListView;

@end

@implementation RYUserListCollectionViewCell

- (void) configureWithUser:(RYUser *)user
{
    
}

#pragma mark -
#pragma mark - LifeCycle

+ (CGSize) preferredSizeWithAvailableSize:(CGSize)boundingSize forUser:(RYUser *)user
{
    CGFloat heightMinusText = 255.0f;
    CGFloat widthMinusText = 16.0f;
    
    UITextView *sizingTextView        = [[UITextView alloc] init];
    sizingTextView.textContainerInset = UIEdgeInsetsZero;
    sizingTextView.text               = user.bio;
    CGFloat height = [sizingTextView sizeThatFits:CGSizeMake(boundingSize.width-widthMinusText, boundingSize.height)].height;
    
    return CGSizeMake(boundingSize.width, height+heightMinusText);
}

#pragma mark -
#pragma mark - Actions

- (IBAction)followButtonHit:(id)sender
{
    
}

@end
