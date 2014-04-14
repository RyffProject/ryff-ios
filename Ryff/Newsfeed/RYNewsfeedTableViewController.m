//
//  RYNewsfeedTableViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYNewsfeedTableViewController.h"

// UI
#import "UIImage+Color.h"

// Data Managers
#import "RYServices.h"

@interface RYNewsfeedTableViewController () <UITableViewDataSource, UITableViewDelegate, POSTDelegate>

@end

@implementation RYNewsfeedTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up test data
    self.feedItems = @[];
    self.isPlaying = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[RYServices sharedInstance] getFriendPostsForDelegate:self];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self clearRiffDownloading];
}

#pragma mark -
#pragma mark - Post Delegate
- (void) connectionFailed
{
    
}
- (void) postFailed:(NSString*)reason
{
    
}
- (void) postSucceeded:(id)response
{
    NSDictionary *responseDict = response;
    NSArray *posts = [responseDict objectForKey:@"posts"];
    
    NSMutableArray *myPosts = [[NSMutableArray alloc] init];
    
    for (NSDictionary *postDict in posts)
    {
        RYNewsfeedPost *post = [RYNewsfeedPost newsfeedPostWithDict:postDict];
        [myPosts addObject:post];
    }
    [self setFeedItems:myPosts];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.feedItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:section];
    NSInteger numCells = (post.riff) ? 2 : 1;
    return numCells;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
    if (post.riff && indexPath.row == 0)
    {
        RYRiffTrackTableViewCell *riffCell = [tableView dequeueReusableCellWithIdentifier:@"RiffCell" forIndexPath:indexPath];
        cell = (UITableViewCell*) riffCell;
    }
    else
    {
        // user post
        cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
    if (post.riff && indexPath.row == 0)
    {
        RYRiffTrackTableViewCell *riffCell = (RYRiffTrackTableViewCell*)cell;
        UIImage *maskedImage = [[UIImage imageNamed:@"play.png"] imageWithOverlayColor:[RYStyleSheet baseColor]];
        [riffCell.statusImageView setImage:maskedImage];
        
        [riffCell configureForRiff:post.riff];
    }
    else
    {
        NSAttributedString *attributedText = [RYServices createAttributedTextWithPost:post];
        
        [cell.textLabel setAttributedText:attributedText];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0f;
    
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
    if (indexPath.row == 1 || post.riff == NULL)
    {
        CGSize constraint = CGSizeMake(self.view.frame.size.width, 20000);
        NSAttributedString *mainText = [RYServices createAttributedTextWithPost:post];
        CGRect result = [mainText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        height = MAX(result.size.height+20, height);
    }
    return height;
}

#pragma mark -
#pragma mark - UITableView Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RYNewsfeedPost *post = [self.feedItems objectAtIndex:indexPath.section];
    
    // Riff row
    if (post.riff && indexPath.row == 0)
    {
        // if not playing, begin
        if (!self.isPlaying)
        {
            self.isPlaying = YES;
            self.currentlyPlayingCell = (RYRiffTrackTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            [self startRiffDownload:post.riff];
            return;
        }
        
        // stop any downloads
        else if (self.isDownloading)
            [self clearRiffDownloading];
        
        // already playing
        else if ([tableView indexPathForCell:self.currentlyPlayingCell].section == indexPath.section)
        {
            //currently playing this track, pause it
            if (self.audioPlayer.isPlaying)
            {
                [self.audioPlayer pause];
                [self.currentlyPlayingCell shouldPause:YES];
            }
            else
            {
                [self.audioPlayer play];
                [self.currentlyPlayingCell shouldPause:NO];
            }
        }
        else
        {
            //playing another, switch riff
            [self.currentlyPlayingCell setLoadingStatus:STOP];
            [self clearRiffDownloading];
            
            self.isPlaying = YES;
            self.currentlyPlayingCell = (RYRiffTrackTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            [self startRiffDownload:post.riff];
        }
    }
    else
    {
        // open new view controller for chosen user
        
    }
}

@end
