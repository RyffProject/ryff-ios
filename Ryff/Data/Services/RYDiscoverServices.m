//
//  RYDiscoverServices.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYDiscoverServices.h"

// Data Objects
#import "RYTag.h"

// Frameworks
#import "AFHTTPRequestOperationManager.h"

@implementation RYDiscoverServices

static RYDiscoverServices* _sharedInstance;
+ (instancetype)sharedInstance
{
    if (_sharedInstance == NULL)
    {
        _sharedInstance = [RYDiscoverServices allocWithZone:NULL];
    }
    return _sharedInstance;
}

#pragma mark -
#pragma mark - Search Tags

- (void) tagSearchWithParams:(NSDictionary *)dictionary toAction:(NSString *)action forDelegate:(id<TagDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:action parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = responseObject;
            if (dictionary[@"success"])
            {
                if (delegate && [delegate respondsToSelector:@selector(tagsRetrieved:)])
                    [delegate tagsRetrieved:[RYTag tagsFromDictArray:dictionary[@"tags"]]];
            }
            else
            {
                if (delegate && [delegate respondsToSelector:@selector(tagsFailedToRetrieve:)])
                    [delegate tagsFailedToRetrieve:dictionary[@"error"]];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (delegate && [delegate respondsToSelector:@selector(tagsFailedToRetrieve:)])
                [delegate tagsFailedToRetrieve:[error localizedDescription]];
        }];
    });
}

- (void) searchTagsFor:(NSString *)query delegate:(id<TagDelegate>)delegate
{
    NSDictionary *params = @{@"query":query};
    NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kSearchTags];
    [self tagSearchWithParams:params toAction:action forDelegate:delegate];
}

- (void) getTrendingTagsForDelegate:(id<TagDelegate>)delegate
{
    NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kTrendingTagsAction];
    [self tagSearchWithParams:nil toAction:action forDelegate:delegate];
}

- (void) getSuggestedTagsForDelegate:(id<TagDelegate>)delegate
{
    NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kSuggestedTagsAction];
    [self tagSearchWithParams:nil toAction:action forDelegate:delegate];
}

#pragma mark -
#pragma mark - Search Posts

- (void) searchForPostsWithTags:(NSArray *)tags searchType:(SearchType)searchType delegate:(id<PostDelegate>)delegate
{
    NSDictionary *params = @{@"tags":tags};
    NSString *action = [NSString stringWithFormat:@"%@%@",kApiRoot,kSearchPostsNew];
    [[RYServices sharedInstance] getPostsWithParams:params toAction:action forDelegate:delegate];
}

@end
