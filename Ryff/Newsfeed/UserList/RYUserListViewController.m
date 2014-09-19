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
#import "RYUserListCollectionViewCell.h"

// Associated ViewControllers
#import "RYProfileViewController.h"

#define kUserListCellReuseID @"userListCell"

@interface RYUserListViewController () <UsersDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// Data
@property (nonatomic, strong) NSArray *users;

@end

@implementation RYUserListViewController

#pragma mark - 
#pragma mark - ViewController LifeCycle

- (void) viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Configuration

- (void) configureForUsers:(NSArray *)users title:(NSString *)title
{
    _users = users;
    
    if (title)
        [self setTitle:title];
    
    if (self.view.window && self.isViewLoaded)
        [_collectionView reloadData];
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
        [_collectionView reloadData];
}

#pragma mark -
#pragma mark - CollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RYUser *user = _users[indexPath.row];
    RYUserListCollectionViewCell *userCell = [collectionView dequeueReusableCellWithReuseIdentifier:kUserListCellReuseID forIndexPath:indexPath];
    [userCell configureWithUser:user];
    return userCell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark -
#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RYUser *user = _users[indexPath.row];
    
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYProfileViewController *profileVC = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"profileVC"];
    [profileVC configureForUser:user];
    if (self.navigationController)
        [self.navigationController pushViewController:profileVC animated:YES];
    else
        [self presentViewController:profileVC animated:YES completion:nil];
}

#pragma mark -
#pragma mark - CollectionView Flow Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RYUser *user = _users[indexPath.row];
    return [RYUserListCollectionViewCell preferredSizeWithAvailableSize:CGSizeMake(self.view.frame.size.width/2 - 20, 20000) forUser:user];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 20.0f;
}

@end
