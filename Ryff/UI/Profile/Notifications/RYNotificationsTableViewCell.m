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

// Data Objects
#import "RYNotification.h"
#import "RYPost.h"
#import "RYUser.h"

// Frameworks
#import "UIImageView+SGImageCache.h"

@interface RYNotificationsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@end

@implementation RYNotificationsTableViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [RYStyleSheet styleProfileImageView:_avatarImageView];
    [_topLabel setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    [_bottomLabel setFont:[UIFont fontWithName:kLightFont size:16.0f]];
    [_bottomLabel setTextColor:[RYStyleSheet availableActionColor]];
}

- (void) configureWithNotification:(RYNotification *)notification
{
    NSString *notificationString;
    
    NSMutableString *usersString;
    RYUser *lastUser;
    NSMutableString *postsString;
    NSString *postString;
    
    if (notification.posts)
    {
        RYPost *lastPost = notification.posts.lastObject;
        lastUser = lastPost.user;
        postsString = [lastPost.title mutableCopy];
        if (notification.posts.count == 2)
            [postsString appendFormat:@" and 1 other riff"];
        else if (notification.users.count > 2)
            [postsString appendString:[NSString stringWithFormat:@" and %ld other riffs",(notification.posts.count-1)]];
    }
    
    if (notification.users)
    {
        lastUser = notification.users.lastObject;
        usersString = [lastUser.username mutableCopy];
        if (notification.users.count == 2)
            [usersString appendFormat:@" and 1 other"];
        else if (notification.users.count > 2)
            [usersString appendString:[NSString stringWithFormat:@" and %ld others",(notification.users.count-1)]];
    }
    
    if (notification.post)
    {
        postString = notification.post.title;
    }
    
    switch (notification.type) {
        case FOLLOW_NOTIF:
            notificationString = [NSString stringWithFormat:@"%@ followed you.",usersString];
            break;
        case UPVOTE_NOTIF:
            notificationString = [NSString stringWithFormat:@"%@ upvoted %@",usersString,postString];
            break;
        case REMIX_NOTIF:
            notificationString = [NSString stringWithFormat:@"%@ remixed %@",usersString,postString];
            break;
        case MENTION_NOTIF:
            notificationString = [NSString stringWithFormat:@"You were mentioned in %@",postsString];
            break;
        case UNRECOGNIZED_NOTIF:
            break;
    }
    [_topLabel setText:notificationString];
    
    // avatar image
    if (lastUser)
        [_avatarImageView setImageForURL:lastUser.avatarURL.absoluteString placeholder:[UIImage imageNamed:@"user"]];
    
    // time since
    NSTimeInterval timeSince = [[NSDate date] timeIntervalSinceDate:notification.dateUpdated];
    [_bottomLabel setText:[RYStyleSheet displayTimeWithSeconds:timeSince]];
}

@end
