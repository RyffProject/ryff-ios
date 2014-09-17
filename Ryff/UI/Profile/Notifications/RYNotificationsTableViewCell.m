//
//  RYNotificationsTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNotificationsTableViewCell.h"

// Data Managers
#import "RYStyleSheet.h"
#import "RYNotificationsManager.h"

// Data Objects
#import "RYNotification.h"
#import "RYPost.h"
#import "RYUser.h"

// Frameworks
#import "UIImageView+SGImageCache.h"

@interface RYNotificationsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@end

@implementation RYNotificationsTableViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [RYStyleSheet styleProfileImageView:_avatarImageView];
    [_topLabel setFont:kNotificationsCellFont];
    [_bottomLabel setFont:[UIFont fontWithName:kLightFont size:16.0f]];
    [_bottomLabel setTextColor:[RYStyleSheet availableActionColor]];
    
    _backView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
}

- (void) configureWithNotification:(RYNotification *)notification
{
    
    [_topLabel setText:[RYNotificationsManager notificationString:notification]];
    
    // avatar image
    RYUser *lastUser;
    if (notification.posts)
    {
        RYPost *lastPost = notification.posts.lastObject;
        lastUser = lastPost.user;
    }
    if (notification.users)
    {
        lastUser = notification.users.lastObject;
    }
    
    if (lastUser)
        [_avatarImageView setImageForURL:lastUser.avatarURL.absoluteString placeholder:[UIImage imageNamed:@"user"]];
    
    // time since
    NSTimeInterval timeSince = [[NSDate date] timeIntervalSinceDate:notification.dateUpdated];
    [_bottomLabel setText:[RYStyleSheet displayTimeWithSeconds:timeSince]];
    
    self.backgroundColor = [UIColor clearColor];
}

@end
