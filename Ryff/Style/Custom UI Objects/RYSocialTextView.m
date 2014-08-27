//
//  RYSocialTextView.m
//  Ryff
//
//  Created by Christopher Laganiere on 8/26/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYSocialTextView.h"

// Categories
#import "UIColor+Hex.h"

#define kContentFont [UIFont fontWithName:kRegularFont size:18.0f]

@interface RYSocialTextView () <UITextViewDelegate>

@end

@implementation RYSocialTextView

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.delegate = self;
}

#pragma mark -
#pragma mark - Configuration

- (void) loadContent:(NSString *)content
{
    [self loadAttributedContent:[[NSAttributedString alloc] initWithString:content attributes:nil]];
}

- (void) loadAttributedContent:(NSAttributedString *)attributedContent
{
    self.attributedText = [self highlightUsersAndTags:[attributedContent mutableCopy]];
}

#pragma mark - Internal

/**
 *  Highlight occurences of @username in textview
 *
 *  @param attString the textView's original attributed string
 *
 *  @return new attributed string for textview
 */
- (NSAttributedString *)highlightUsersAndTags:(NSMutableAttributedString *)attString
{
    if (!attString || attString.length == 0)
        return nil;
    
    // First reset attributes for the whole textview
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, attString.string.length)];
    [attString addAttribute:NSFontAttributeName value:kContentFont range:NSMakeRange(0, attString.string.length)];
    
    // @username
    NSString *userPattern = @"(@)";
    NSDictionary *userAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"63c8e0"], NSFontAttributeName: [UIFont fontWithName:kBoldFont size:kContentFont.pointSize]};
    [self applyAttributes:userAttributes toWordsStartingWith:userPattern onAttString:attString linkScheme:@"user"];
    
    // #tag
    NSString *tagPattern = @"(#)";
    NSDictionary *tagAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"63c8e0"]};
    [self applyAttributes:tagAttributes toWordsStartingWith:tagPattern onAttString:attString linkScheme:@"tag"];
    
    return attString;
}

/**
 *  Apply attributes to attString on all occurrences of alpha words beginning with given pattern. Will also apply links if linkScheme is set.
 *
 *  @param attributes dictionary of attributes to apply
 *  @param pattern    pattern to search for
 *  @param attString  the attributed string to modify
 *  @param linkScheme beginning of links to handle locally (host will be the word found)
 */
- (void) applyAttributes:(NSDictionary *)attributes toWordsStartingWith:(NSString *)pattern onAttString:(NSMutableAttributedString *)attString linkScheme:(NSString *)linkScheme
{
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSRange range = NSMakeRange(0,attString.string.length);
    [expression enumerateMatchesInString:attString.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange patternRange = [result rangeAtIndex:1];
        
        // get range within attString to highlight
        NSCharacterSet *workingSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
        NSInteger highlightStartLoc = patternRange.location+1;
        NSRange endRange = [attString.string rangeOfCharacterFromSet:workingSet options:NSLiteralSearch range:NSMakeRange(highlightStartLoc, attString.string.length-highlightStartLoc)];
        NSInteger highlightEndLoc = (endRange.length > 0) ? endRange.location-patternRange.location : attString.string.length-patternRange.location;
        NSRange highlightRange = NSMakeRange(patternRange.location, highlightEndLoc);
        
        // add attributes
        NSMutableDictionary *mutAttributes = [attributes mutableCopy];
        if (linkScheme)
        {
            NSString *highlightedWord = [attString.string substringWithRange:NSMakeRange(highlightRange.location+1, highlightRange.length-1)];
            NSString *linkURL = [NSString stringWithFormat:@"%@://%@",linkScheme,highlightedWord];
            [mutAttributes setObject:linkURL forKey:NSLinkAttributeName];
        }
        
        [attString addAttributes:mutAttributes range:highlightRange];
    }];
}

#pragma mark -
#pragma mark - TextView Delegate

- (void) textViewDidChange:(UITextView *)textView
{
    NSAttributedString *styledString = [self highlightUsersAndTags:[textView.attributedText.string mutableCopy]];
    [self setAttributedText:styledString];
}

/*
 Check each character typed in order to present "@username" placeholder when the user types a '@'
 */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"@"])
    {
        // provide @username placeholder
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"@username" attributes:@{NSForegroundColorAttributeName : [UIColor blueColor], NSFontAttributeName : [UIFont fontWithName:kBoldFont size:kContentFont.pointSize]}];
        [self.textStorage replaceCharactersInRange:range withAttributedString:attString];
        [self setSelectedRange:NSMakeRange(range.location+1, attString.length-1)];
        
        return NO;
    }
    else if ([text isEqualToString:@"#"])
    {
        // provide @username placeholder
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"#tag" attributes:@{NSForegroundColorAttributeName : [UIColor blueColor], NSFontAttributeName : [UIFont fontWithName:kBoldFont size:kContentFont.pointSize]}];
        [self.textStorage replaceCharactersInRange:range withAttributedString:attString];
        [self setSelectedRange:NSMakeRange(range.location+1, attString.length-1)];
        
        return NO;
    }
    return YES;
}

// link clicked, notify socialDelegate if possible
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if ([[URL scheme] isEqualToString:@"user"])
    {
        NSString *username = [URL host];
        if (_socialDelegate && [_socialDelegate respondsToSelector:@selector(presentProfileForUsername:)])
            [_socialDelegate presentProfileForUsername:username];
        return NO;
    }
    else if ([[URL scheme] isEqualToString:@"tag"])
    {
        NSString *tag = [URL host];
        if (_socialDelegate && [_socialDelegate respondsToSelector:@selector(presentNewsfeedForTag:)])
            [_socialDelegate presentNewsfeedForTag:tag];
        return NO;
    }
    return YES; // let the system open this URL
}

@end
