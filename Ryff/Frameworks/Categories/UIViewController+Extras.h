//
//  UIViewController+Extras.h
//  LSATMax
//
//  Created by Jason Loewy on 7/20/12.
//  Copyright (c) 2012 Jason Loewy. All rights reserved.
//

@interface UIViewController (Extras)

- (void) showHUDWithTitle:(NSString*) title;

- (void) showCheckHUDWithTitle:(NSString *)title forDuration:(NSTimeInterval)duration;

- (void) hideHUD;

@end
