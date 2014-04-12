//
//  RYServices.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYServices.h"

// Data Objects
#import "RYUser.h"
#import "RYNewsfeedPost.h"

// Custom UI
#import "RYStyleSheet.h"

@implementation RYServices

static RYServices* _sharedInstance;

+ (RYServices *)sharedInstance
{
    if (_sharedInstance == NULL)
    {
        _sharedInstance = [RYServices allocWithZone:NULL];
    }
    return _sharedInstance;
}

+ (RYUser *)loggedInUser
{
    return [RYUser patrick];
}

#pragma mark -
#pragma mark - Extras
+ (NSAttributedString *)createAttributedTextWithPost:(RYNewsfeedPost *)post
{
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [RYStyleSheet boldFont], NSFontAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              [RYStyleSheet baseFont], NSFontAttributeName, nil];
    const NSRange range = NSMakeRange(0,post.username.length);
    
    // Create the attributed string (text + attributes)
    NSString *fullText = [NSString stringWithFormat:@"%@ %@",post.username,post.mainText];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText
                                                                                       attributes:subAttrs];
    [attributedText setAttributes:attrs range:range];
    return attributedText;
}

@end