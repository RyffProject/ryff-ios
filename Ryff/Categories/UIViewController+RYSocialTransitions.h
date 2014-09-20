//
//  UIViewController+RYSocialTransitions.h
//  Ryff
//
//  Created by Christopher Laganiere on 9/19/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYUser;
@class RYPost;

@interface UIViewController (RYSocialTransitions)

- (void) pushUserProfileForUser:(RYUser *)user;
- (void) pushUserProfileForUsername:(NSString *)username;
- (void) pushRiffDetailsForPost:(RYPost *)post;
- (void) pushTagFeedForTags:(NSArray *)arrayOfTagStrings;
- (void) pushFollowersViewControllerForUser:(RYUser *)user;

@end
