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
#import "RYStyleSheet.h"

// Data Objects
#import "RYTag.h"
#import "RYTagList.h"

// Custom UI
#import "RYTagCollectionViewCell.h"

// Categories
#import "UIViewController+RYSocialTransitions.h"

#define kTagCellReuseID @"tagCell"

@interface RYTagListViewController () <TagListDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

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
    trending.delegate = self;
    suggested.delegate = self;
    [trending fetchData];
    [suggested fetchData];
    
    _tagLists = @[trending, suggested];
    
    self.view.backgroundColor = [RYStyleSheet lightBackgroundColor];
    
    self.title = @"Discover";
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark -
#pragma mark - TagListCollectionContainer Delegate

- (void) tagSelected:(RYTag *)tag
{
    [self pushTagFeedForTags:@[tag.tag]];
}

#pragma mark -
#pragma mark - TagList Delegate

- (void) tagsUpdated
{
    [_collectionView reloadData];
}

#pragma mark -
#pragma mark - CollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    RYTagList *tagList = _tagLists[section];
    return tagList.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RYTagList *tagList = _tagLists[indexPath.section];
    RYTag *tag = tagList.list[indexPath.row];
    RYTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTagCellReuseID forIndexPath:indexPath];
    [cell configureWithTag:tag];
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _tagLists.count;
}

#pragma mark -
#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RYTagList *tagList = _tagLists[indexPath.section];
    RYTag *selectedTag = tagList.list[indexPath.row];
    [self pushTagFeedForTags:@[selectedTag.tag]];
}

#pragma mark -
#pragma mark - CollectionView Flow Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(150, 150);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(17.5, 17.5, 17.5, 17.5);
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
