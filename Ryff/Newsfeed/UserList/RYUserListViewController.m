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
#import "CHTCollectionViewWaterfallLayout.h"

// Categories
#import "UIViewController+RYSocialTransitions.h"

#define kUserListCellReuseID @"userListCell"

@interface RYUserListViewController () <UsersDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout, UserListCellDelegate, FollowDelegate>

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
    
    CHTCollectionViewWaterfallLayout *waterfall = [[CHTCollectionViewWaterfallLayout alloc] init];
    waterfall.columnCount = isIpad ? 2 : 1;
    waterfall.minimumColumnSpacing = 20.0f;
    waterfall.minimumInteritemSpacing = 20.0f;
    waterfall.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    waterfall.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst;
    
    _collectionView.collectionViewLayout = waterfall;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_collectionView.collectionViewLayout invalidateLayout];
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
    [self setTitle:@"Followers"];
    
    [[RYServices sharedInstance] getFollowersForUser:user.userId page:0 delegate:self];
}

#pragma mark -
#pragma mark - UserListCell Delegate

- (void) followUserTapped:(RYUser *)user
{
    [[RYServices sharedInstance] follow:!user.isFollowing user:user.userId forDelegate:self];
}

- (void) tagSelected:(NSString *)tag
{
    [self pushTagFeedForTags:@[tag]];
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
#pragma mark - Follow Delegate

- (void) follow:(BOOL)following confirmedForUser:(RYUser *)user
{
    for (NSInteger userIdx = 0; userIdx < _users.count; userIdx++)
    {
        RYUser *oldUser = _users[userIdx];
        if (oldUser.userId == user.userId)
        {
            NSMutableArray *mutableUsers = [_users mutableCopy];
            [mutableUsers replaceObjectAtIndex:userIdx withObject:user];
            _users = mutableUsers;
            [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:userIdx inSection:0]]];
        }
    }
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
    [userCell configureWithUser:user delegate:self];
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
    [self pushUserProfileForUser:user];
}

#pragma mark -
#pragma mark - CHTCollectionViewDelegateWaterfallLayout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RYUser *user = _users[indexPath.row];
    CGFloat availableWidth = isIpad ? self.view.frame.size.width/2 - 40 : self.view.frame.size.width;
    return [RYUserListCollectionViewCell preferredSizeWithAvailableSize:CGSizeMake(availableWidth, 20000) forUser:user];
}

@end
