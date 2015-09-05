//
//  RYDiscoverViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYDiscoverViewController.h"

// Data Managers
#import "RYRegistrationServices.h"
#import "RYDiscoverServices.h"
#import "RYStyleSheet.h"

// Data Objects
#import "RYTag.h"
#import "RYTagList.h"

// Custom UI
#import "RYTagCollectionViewCell.h"
#import "RYTagListHeaderView.h"

// Categories
#import "UIViewController+RYSocialTransitions.h"

#define kTagCellReuseID @"tagCell"
#define kTagHeaderReuseID @"tagListHeader"

@interface RYDiscoverViewController () <TagListDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) UICollectionView *collectionView;

// Data
@property (nonatomic) NSArray *tagLists;

@end

@implementation RYDiscoverViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.collectionView];
    NSDictionary *viewsDict = @{@"collectionView": self.collectionView};
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:0 metrics:nil views:viewsDict]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:viewsDict]];
    
    [self.collectionView registerClass:[RYTagCollectionViewCell class] forCellWithReuseIdentifier:kTagCellReuseID];
    [self.collectionView registerClass:[RYTagListHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kTagHeaderReuseID];
    
    NSMutableArray *tagLists = [[NSMutableArray alloc] initWithCapacity:2];
    
    RYTagList *trending = [[RYTagList alloc] initWithTagListType:TRENDING_LIST];
    trending.delegate = self;
    [trending fetchData];
    [tagLists addObject:trending];
    
    if ([RYRegistrationServices loggedInUser])
    {
        // suggested tag list requires logged in user
        RYTagList *suggested = [[RYTagList alloc] initWithTagListType:SUGGESTED_LIST];
        suggested.delegate = self;
        [suggested fetchData];
        [tagLists addObject:suggested];
        
        RYTagList *myTags = [[RYTagList alloc] initWithTagListType:MY_LIST];
        myTags.delegate = self;
        [myTags fetchData];
        [tagLists addObject:myTags];
    }
    
    _tagLists = tagLists;
    
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
    return [collectionView dequeueReusableCellWithReuseIdentifier:kTagCellReuseID forIndexPath:indexPath];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kTagHeaderReuseID forIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _tagLists.count;
}

#pragma mark -
#pragma mark - CollectionView Delegate

- (void) collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    RYTagList *tagList = _tagLists[indexPath.section];
    RYTag *tag = tagList.list[indexPath.row];
    [((RYTagCollectionViewCell *)cell) configureWithTag:tag];
}

- (void) collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    RYTagList *tagList = _tagLists[indexPath.section];
    [((RYTagListHeaderView *)view) titleSection:tagList.listTitle];
}

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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize headerSize;
    RYTagList *tagList = _tagLists[section];
    if (tagList.listType == SEARCH)
        headerSize = CGSizeZero;
    else
        headerSize = CGSizeMake(self.view.frame.size.width, 50.0f);
    return headerSize;
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
