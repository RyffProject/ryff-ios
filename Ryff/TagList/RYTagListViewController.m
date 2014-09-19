//
//  RYTagListViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYTagListViewController.h"

// Data Managers
#import "RYDiscoverServices.h"

// Data Objects
#import "RYTag.h"
#import "RYTagList.h"

// Custom UI
#import "RYTagListCollectionContainerCell.h"

// Associated View Controllers
#import "RYTagFeedViewController.h"

#define kTagListContainerCellReuseID @"tagListContainerCell"

@interface RYTagListViewController () <TagListCollectionContainerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// Data
@property (nonatomic, strong) NSArray *tagLists;

@end

@implementation RYTagListViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    RYTagList *trending = [[RYTagList alloc] initWithTagListType:TRENDING_LIST];
    RYTagList *suggested = [[RYTagList alloc] initWithTagListType:SUGGESTED_LIST];
    
    [trending fetchData];
    [suggested fetchData];
    
    _tagLists = @[trending, suggested];
    
    self.view.backgroundColor = [RYStyleSheet profileBackgroundColor];
    
    self.title = @"Discover";
}

#pragma mark -
#pragma mark - TagListCollectionContainer Delegate

- (void) tagSelected:(RYTag *)tag
{
    NSString *storyboardName = isIpad ? @"Main" : @"MainIphone";
    RYTagFeedViewController *tagFeed = [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:@"tagFeedVC"];
    [tagFeed configureWithTags:@[tag.tag]];
    [self.navigationController pushViewController:tagFeed animated:YES];
}

#pragma mark -
#pragma mark - CollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _tagLists.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RYTagList *tagList = _tagLists[indexPath.row];
    RYTagListCollectionContainerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTagListContainerCellReuseID forIndexPath:indexPath];
    [cell configureWithTagList:tagList delegate:self];
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark -
#pragma mark - CollectionView Flow Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, 235);
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
