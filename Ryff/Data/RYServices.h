//
//  RYServices.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RiffDownloadDelegate <NSObject>

- (void) riffDownloadStarted;
- (void) riffDownloadFinished;

@end

@class RYUser;

@interface RYServices : NSObject

+ (RYServices *)sharedInstance;

+ (RYUser *) loggedInUser;

@end
