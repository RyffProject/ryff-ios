//
//  RYUserListViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 8/22/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYUserListViewController.h"

// Data Managers
#import "RYServices.h"

// Data Objects
#import "RYUser.h"

// Custom UI
#import "RYUserListTableViewCell.h"

// Associated ViewControllers
#import "RYProfileViewController.h"

#define kUserListCellReuseID @"userListCell"

@interface RYUserListViewController () <UsersDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, strong) NSArray *users;

@end

@implementation RYUserListViewController

#pragma mark - 
#pragma mark - ViewController LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

#pragma mark - Configuration

- (void) configureForUsers:(NSArray *)users title:(NSString *)title
{
    _users = users;
    
    if (title)
        [self setTitle:title];
    
    if (self.view.window && self.isViewLoaded)
        [_tableView reloadData];
}

- (void) configureWithFollowersForUser:(RYUser *)user
{
    NSString *username = user.nickname.length > 0 ? user.nickname : user.username;
    [self setTitle:[NSString stringWithFormat:@"Following %@",username]];
    
    [[RYServices sharedInstance] getFollowersForUser:user.userId page:0 delegate:self];
}

#pragma mark -
#pragma mark - UsersDelegate

- (void) retrievedUsers:(NSArray *)users
{
    _users = users;
    
    if (self.view.window && self.isViewLoaded)
        [_tableView reloadData];
}

#pragma mark -
#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _users.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:kUserListCellReuseID];
}

#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RYUser *user = _users[indexPath.row];
    
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYProfileViewController *profileVC = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"profileVC"];
    [profileVC configureForUser:user];
    if (self.navigationController)
        [self.navigationController pushViewController:profileVC animated:YES];
    else
        [self presentViewController:profileVC animated:YES completion:nil];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RYUser *user = _users[indexPath.row];
    [(RYUserListTableViewCell*)cell configureForUser:user];
}

@end
