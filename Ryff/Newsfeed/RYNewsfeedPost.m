//
//  RYNewsfeedPost.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNewsfeedPost.h"

// Data Objects
#import "RYRiff.h"
#import "RYUser.h"

@implementation RYNewsfeedPost

- (RYNewsfeedPost *)initWithUsername:(NSString *)username mainText:(NSString*)mainText riff:(RYRiff*)riff
{
    if (self = [super init])
    {
        _username   = username;
        _mainText   = mainText;
        _riff       = riff;
    }
    return self;
}

+ (NSArray *)testNewsfeedPosts
{
    NSMutableArray *feedItems = [[NSMutableArray alloc] init];
    
    NSString *username = @"patrickCarney";
    RYRiff *nextgirl = [[RYRiff alloc] initWithTitle:@"Next Girl" length:180 url:@"http://danielawrites.files.wordpress.com/2010/05/the-black-keys-next-girl.mp3"];
    RYNewsfeedPost *testPost = [[RYNewsfeedPost alloc] initWithUsername:username mainText:@"A new song we've been working on..." riff:nextgirl];
    [feedItems addObject:testPost];
    
    RYRiff *psychoticGirl = [[RYRiff alloc] initWithTitle:@"Psychotic Girl" length:180 url:@"http://saharalotti.com/music/04%20Psychotic%20Girl.mp3"];
    RYNewsfeedPost *testPost2 = [[RYNewsfeedPost alloc] initWithUsername:username mainText:@"Check this out! About no one in particular of course... :) Let's jam!" riff:psychoticGirl];
    [feedItems addObject:testPost2];
    
    return feedItems;
}

@end
