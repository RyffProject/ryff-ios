//
//  RYArtistSuggestViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYArtistSuggestPageViewController.h"

// Data Managers
#import "RYServices.h"

// Data Objects
#import "RYUser.h"

// Associated View Controllers
#import "RYArtistViewController.h"

// Custom UI
#import "RYStyleSheet.h"

#define kArtistGroupSize 5

@interface RYArtistSuggestPageViewController () <ArtistsFetchDelegate>

@end

@implementation RYArtistSuggestPageViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[RYServices sharedInstance] setArtistsDelegate:self];
    [[RYServices sharedInstance] moreArtistsOfCount:kArtistGroupSize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToNextPage) name:@"next" object:nil];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[RYServices sharedInstance] setArtistsDelegate:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Artists Fetch Delegate

- (void) retrievedArtists:(NSArray *)artists
{
    if (!_artists)
        _artists = @[];
    
    _artists = [_artists arrayByAddingObjectsFromArray:artists];
    
    if ([self.viewControllers firstObject] == NULL)
    {
        // initialize the list
        NSArray *newVCs = @[[self viewControllerAtIndex:0]];
        [self setViewControllers:newVCs direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark - UI
- (void) goToNextPage
{
    UINavigationController *currentNC = [self.viewControllers objectAtIndex:0];
    RYArtistViewController *currentPage = [currentNC.viewControllers firstObject];
    NSInteger index = currentPage.pageIndex;
    if (index < ([_artists count] - 1))
    {
        index++;
        UINavigationController *navCon = (UINavigationController*)[self viewControllerAtIndex:index];
        RYArtistViewController *newVC = [navCon.viewControllers firstObject];
        [newVC setArtist:[_artists objectAtIndex:index]];
        
        NSArray *viewControllers = @[navCon];
        [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (_artists.count == 0 || (index >= _artists.count)) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    UINavigationController *artistNC = [self.storyboard instantiateViewControllerWithIdentifier:@"ArtistNC"];
    RYArtistViewController *artistPage = [[artistNC viewControllers] firstObject];
    [artistPage setArtist:[_artists objectAtIndex:index]];
    [artistPage setPageIndex:index];
    
    return artistNC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((RYArtistViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((RYArtistViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    if (index >= _artists.count-3)
    {
        [[RYServices sharedInstance] moreArtistsOfCount:kArtistGroupSize];
    }
    
    index++;
    if (index == _artists.count) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

@end
