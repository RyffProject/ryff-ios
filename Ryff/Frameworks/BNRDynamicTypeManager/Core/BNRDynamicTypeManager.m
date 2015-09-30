//
//  BNRDynamicTypeManager.m
//  BNRDynamicTypeManager
//
//  Created by John Gallagher on 1/9/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRDynamicTypeManager.h"

// Custom UI
#import "RYStyleSheet.h"

static NSString * const BNRDynamicTypeManagerFontKeypathUILabel     = @"font";
static NSString * const BNRDynamicTypeManagerFontKeypathUIButton    = @"titleLabel.font";
static NSString * const BNRDynamicTypeManagerFontKeypathUITextField = @"font";
static NSString * const BNRDynamicTypeManagerFontKeypathUITextView  = @"font";

#pragma mark - BNRDynamicTypeTuple interface

// Helper class that we'll use as values in our NSMapTable to hold
// (keypath, textStyle) tuples.
@interface BNRDynamicTypeTuple : NSObject

@property (nonatomic, copy) NSString *keypath;
@property (nonatomic, copy) NSString *textStyle;
@property (nonatomic, assign) FontStyle fontStyle;

- (instancetype)initWithKeypath:(NSString *)keypath textStyle:(NSString *)textStyle fontStyle:(FontStyle)fontStyle;

@end

#pragma mark - BNRDynamicTypeManager class extension

@interface BNRDynamicTypeManager ()

@property (nonatomic, strong) NSMapTable *elementToTupleTable;

@end

@implementation BNRDynamicTypeManager

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    static BNRDynamicTypeManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BNRDynamicTypeManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Class Methods

+ (NSString *)textStyleMatchingFont:(UIFont *)font
{
    static NSArray *textStyles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        textStyles = @[UIFontTextStyleBody,
                       UIFontTextStyleCaption1,
                       UIFontTextStyleCaption2,
                       UIFontTextStyleFootnote,
                       UIFontTextStyleHeadline,
                       UIFontTextStyleSubheadline];
    });

    for (NSString *style in textStyles) {
        if ([font isEqual:[RYStyleSheet customFontForTextStyle:style]]) {
            return style;
        }
    }

    return nil;
}

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _elementToTupleTable = [NSMapTable weakToStrongObjectsMapTable];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(noteContentSizeCategoryDidChange:)
                                                     name:UIContentSizeCategoryDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public API

- (void)watchLabel:(UILabel *)label textStyle:(NSString *)style fontStyle:(FontStyle)fontStyle
{
    [self watchElement:label fontKeypath:BNRDynamicTypeManagerFontKeypathUILabel textStyle:style fontStyle:fontStyle];
}

- (void)watchButton:(UIButton *)button textStyle:(NSString *)style fontStyle:(FontStyle)fontStyle
{
    [self watchElement:button fontKeypath:BNRDynamicTypeManagerFontKeypathUIButton textStyle:style fontStyle:fontStyle];
}

- (void)watchTextField:(UITextField *)textField textStyle:(NSString *)style fontStyle:(FontStyle)fontStyle
{
    [self watchElement:textField fontKeypath:BNRDynamicTypeManagerFontKeypathUITextField textStyle:style fontStyle:fontStyle];
}

- (void)watchTextView:(UITextView *)textView textStyle:(NSString *)style fontStyle:(FontStyle)fontStyle
{
    [self watchElement:textView fontKeypath:BNRDynamicTypeManagerFontKeypathUITextView textStyle:style fontStyle:fontStyle];
}

- (void)watchElement:(id)element fontKeypath:(NSString *)fontKeypath textStyle:(NSString *)style fontStyle:(FontStyle)fontStyle
{
    if (!style) {
        style = [BNRDynamicTypeManager textStyleMatchingFont:[element valueForKeyPath:fontKeypath]];
    }
    if (fontKeypath && style) {
        
        switch (fontStyle) {
            case FontStyleRegular:
                [element setValue:[RYStyleSheet customFontForTextStyle:style] forKeyPath:fontKeypath];
                break;
            case FontStyleBold:
                [element setValue:[RYStyleSheet boldCustomFontForTextStyle:style] forKey:fontKeypath];
                break;
        }

        BNRDynamicTypeTuple *tuple = [[BNRDynamicTypeTuple alloc] initWithKeypath:fontKeypath textStyle:style fontStyle:fontStyle];
        [self.elementToTupleTable setObject:tuple
                                     forKey:element];
    }
}

#pragma mark - Notifications

- (void)noteContentSizeCategoryDidChange:(NSNotification *)note // UIContentSizeCategoryDidChangeNotification
{
    NSMapTable *elementToTupleTable = self.elementToTupleTable;

    for (id element in elementToTupleTable) {
        BNRDynamicTypeTuple *tuple = [elementToTupleTable objectForKey:element];
        switch (tuple.fontStyle) {
            case FontStyleRegular:
                [element setValue:[RYStyleSheet customFontForTextStyle:tuple.textStyle] forKeyPath:tuple.keypath];
                break;
            case FontStyleBold:
                [element setValue:[RYStyleSheet boldCustomFontForTextStyle:tuple.textStyle] forKey:tuple.keypath];
                break;
        }
    }
}

@end

#pragma mark - BNRDynamicTypeTuple implementation

@implementation BNRDynamicTypeTuple

- (instancetype)initWithKeypath:(NSString *)keypath textStyle:(NSString *)textStyle fontStyle:(FontStyle)fontStyle
{
    self = [super init];
    if (self) {
        self.keypath = keypath;
        self.textStyle = textStyle;
        self.fontStyle = fontStyle;
    }
    return self;
}

@end
