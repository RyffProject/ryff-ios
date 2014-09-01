//
//  RYSocialTextView.h
//  Ryff
//
//  Created by Christopher Laganiere on 8/26/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SocialTextViewDelegate <NSObject>
- (void) presentProfileForUsername:(NSString *)username;
- (void) presentNewsfeedForTag:(NSString *)tag;
@end

@interface RYSocialTextView : UITextView

@property (nonatomic, weak) id<SocialTextViewDelegate> socialDelegate;

@property (nonatomic, strong) UIColor *colorForContentText;

- (void) loadContent:(NSString *)content;
- (void) loadAttributedContent:(NSAttributedString *)attributedContent;

@end
