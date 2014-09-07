//
//  UIImagePickerController+Orientations.m
//  Ryff
//
//  Created by Christopher Laganiere on 9/7/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "UIImagePickerController+Orientations.h"

@implementation UIImagePickerController (Orientations)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
