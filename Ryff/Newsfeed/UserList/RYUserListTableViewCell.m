//
//  RYUserListTableViewCell.m
//  Ryff
//
//  Created by Christopher Laganiere on 8/22/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYUserListTableViewCell.h"

// Data Managers
#import "RYStyleSheet.h"

// Data Objects
#import "RYUser.h"

// Frameworks
#import "UIImageView+WebCache.h"

@interface RYUserListTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *karmaLabel;

@end

@implementation RYUserListTableViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [RYStyleSheet styleProfileImageView:_avatarImageView];
    [_usernameLabel setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    [_karmaLabel setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
}

- (void) configureForUser:(RYUser *)user
{
    if (user.avatarURL.absoluteString.length > 0)
        [_avatarImageView sd_setImageWithURL:user.avatarURL placeholderImage:[UIImage imageNamed:@"user"]];
    else
        [_avatarImageView setImage:[UIImage imageNamed:@"user"]];
    
    NSString *username = user.nickname.length > 0 ? user.nickname : user.username;
    [_usernameLabel setText:username];
    
    [_karmaLabel setText:[NSString stringWithFormat:@"%ld Karma",(long)user.karma]];
    
    [self setBackgroundColor:[UIColor clearColor]];
}

@end
