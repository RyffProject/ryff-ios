//
//  UIViewController+RYSocialTransitions.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/19/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "UIViewController+RYSocialTransitions.h"

// Data Objects
#import "RYTagList.h"
#import "RYUser.h"
#import "RYPost.h"

// Associated View Controllers
#import "RYUserListViewController.h"
#import "RYTagFeedViewController.h"
#import "RYProfileViewController.h"
#import "RYRiffDetailsViewController.h"

@implementation UIViewController (RYSocialTransitions)

- (void) pushUserProfileForUser:(RYUser *)user
{
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYProfileViewController *profileVC = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"profileVC"];
    [profileVC configureForUser:user];
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void) pushUserProfileForUsername:(NSString *)username
{
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYProfileViewController *profileVC = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"profileVC"];
    [profileVC configureForUsername:username];
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void) pushRiffDetailsForPost:(RYPost *)post
{
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYRiffDetailsViewController *riffDetails = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"riffDetails"];
    [riffDetails configureForPost:post];
    [self.navigationController pushViewController:riffDetails animated:YES];
}

- (void) pushTagFeedForTags:(NSArray *)arrayOfTagStrings
{
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYTagFeedViewController *feedVC = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"tagFeedVC"];
    [feedVC configureWithTags:arrayOfTagStrings];
    [self.navigationController pushViewController:feedVC animated:YES];
}

- (void) pushFollowersViewControllerForUser:(RYUser *)user
{
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYUserListViewController *userList = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"userListVC"];
    [userList configureWithFollowersForUser:user];
    [self.navigationController pushViewController:userList animated:YES];
}

@end
