//
//  RYArtistSuggestViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYArtistSuggestPageViewController.h"

// Data Objects
#import "RYUser.h"

// Associated View Controllers
#import "RYArtistViewController.h"

@interface RYArtistSuggestPageViewController ()

@end

@implementation RYArtistSuggestPageViewController


#pragma mark - Page View Controller Data Source

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (_artists.count == 0 || (index >= _artists.count)) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    UINavigationController *artistNC = [self.storyboard instantiateViewControllerWithIdentifier:@"ArtistNC"];
    RYArtistViewController *artistPage = [[artistNC viewControllers] firstObject];
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
    
    index++;
    if (index == _artists.count) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

@end
