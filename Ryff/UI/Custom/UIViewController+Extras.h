//
//  UIViewController+Extras.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

@interface UIViewController (Extras)

- (void) showHUDWithTitle:(NSString*) title;

- (void) showCheckHUDWithTitle:(NSString *)title forDuration:(NSTimeInterval)duration;

- (void) hideHUD;

@end
