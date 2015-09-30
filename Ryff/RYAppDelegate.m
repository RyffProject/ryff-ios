//
//  RYAppDelegate.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/11/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYAppDelegate.h"

// Data Managers
#import "RYServices.h"
#import "RYRegistrationServices.h"
#import "RYDataManager.h"
#import "RYNotificationsManager.h"

// Frameworks
@import SSKeychain;
#import "Crittercism.h"

// View Controllers
#import "RYTabBarViewController.h"

@interface RYAppDelegate ()

@property (nonatomic) RYTabBarViewController *tabBarViewController;

@end

@implementation RYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // log crash events
    [Crittercism enableWithAppID:@"5421e1f8b573f17c9b000004"];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _tabBarViewController = [[RYTabBarViewController alloc] init];
    self.window.rootViewController = self.tabBarViewController;
    [self.window makeKeyAndVisible];
    
    [[RYRegistrationServices sharedInstance] attemptBackgroundLogIn];
    
    // light content 
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Clear caches
    [[RYDataManager sharedInstance] clearCache];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark - Media Control

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    RYAudioDeck *audioDeck = [RYAudioDeck sharedAudioDeck];
    if(event.type == UIEventTypeRemoteControl)
    {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [audioDeck play];
                break;
            case UIEventSubtypeRemoteControlPause:
                [audioDeck pause];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if (audioDeck.isPlaying) {
                    [audioDeck pause];
                }
                else {
                    [audioDeck play];
                }
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [audioDeck skip];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [audioDeck setPlaybackProgress:0.0f];
                break;
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark - Caching

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    // clear caches
    [[RYDataManager sharedInstance] clearCache];
}

#pragma mark -
#pragma mark - Push Notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *rawToken = [[NSString stringWithFormat:@"%@",deviceToken] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	NSString *token    = [rawToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[RYNotificationsManager sharedInstance] updatePushToken:token];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    
}

- (void) application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

@end
