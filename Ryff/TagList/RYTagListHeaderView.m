//
//  RYTagListHeaderView.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/22/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYTagListHeaderView.h"

// Data Managers
#import "RYStyleSheet.h"

// Frameworks
#import "BNRDynamicTypeManager.h"

@interface RYTagListHeaderView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation RYTagListHeaderView

- (void) titleSection:(NSString *)title
{
    _titleLabel.text = title;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    _titleLabel.textColor = [RYStyleSheet darkTextColor];
    [[BNRDynamicTypeManager sharedInstance] watchLabel:_titleLabel textStyle:UIFontTextStyleHeadline fontStyle:FONT_BOLD];
}

@end
