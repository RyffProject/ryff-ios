//
//  RYRiffDetailsTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 7/30/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRiffDetailsTableViewCell.h"

// Data Managers
#import "RYStyleSheet.h"

// Data Objects
#import "RYPost.h"
#import "RYUser.h"

// Categories
#import "UIImageView+WebCache.h"

@interface RYRiffDetailsTableViewCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation RYRiffDetailsTableViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    UITapGestureRecognizer *avatarGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageTapped:)];
    [_avatarImageView addGestureRecognizer:avatarGesture];
    [_avatarImageView setUserInteractionEnabled:YES];
    [RYStyleSheet styleProfileImageView:_avatarImageView];
}

- (void) configureWithPost:(RYPost *)post postIdx:(NSInteger)postIdx actionString:(NSString *)actionString delegate:(id<RiffDetailsDelegate>)delegate
{
    [self configureWithSampledPost:post user:post.user postIdx:postIdx actionString:actionString delegate:delegate];
}

- (void) configureWithSampledPost:(RYPost *)post user:(RYUser *)user postIdx:(NSInteger)postIdx actionString:(NSString *)actionString delegate:(id<RiffDetailsDelegate>)delegate
{
    if (post)
    {
        _delegate = delegate;
        _postIdx  = postIdx;
        
        NSMutableAttributedString *username = [[NSMutableAttributedString alloc] initWithString:user.username attributes:@{NSFontAttributeName: [UIFont fontWithName:kBoldFont size:18.0f]}];
        NSAttributedString *action   = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ %@", actionString, post.title] attributes:@{NSFontAttributeName : [UIFont fontWithName:kRegularFont size:18.0f]}];
        
        [username appendAttributedString:action];
        [_actionLabel setAttributedText:username];
        
        [_timeLabel setAttributedText:[[NSAttributedString alloc] initWithString:@"2 minutes ago" attributes:@{NSFontAttributeName: [UIFont fontWithName:kItalicFont size:18.0f]}]];
        
        [_avatarImageView sd_setImageWithURL:user.avatarURL placeholderImage:[UIImage imageNamed:@"user"]];
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void) configureWithAttributedString:(NSAttributedString *)attString imageURL:(NSURL *)url
{
    _postIdx = -1;
    
    [_actionLabel setAttributedText:attString];
    [_timeLabel setText:@""];
    [_avatarImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"user"]];
    
    [self setBackgroundColor:[UIColor clearColor]];
}

#pragma mark -
#pragma mark - Actions

- (void) avatarImageTapped:(UITapGestureRecognizer *)tapGesture
{
    if (_postIdx >= 0 && _delegate && [_delegate respondsToSelector:@selector(riffAvatarTapAction:)])
        [_delegate riffAvatarTapAction:_postIdx];
}

@end
