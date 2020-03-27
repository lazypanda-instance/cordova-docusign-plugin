//
//  DSNavigationFadeSegue.m
//  DocuSignIt
//
//  Created by Deyton Sehn on 7/17/12.
//  Copyright (c) 2012 DocuSign, Inc. All rights reserved.
//

#import "DSNavigationFadeSegue.h"
#import <QuartzCore/QuartzCore.h>

@implementation DSNavigationFadeSegue

- (void)perform {
    if ([[self.sourceViewController parentViewController] isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)[self.sourceViewController parentViewController];
        UIGraphicsBeginImageContextWithOptions(navController.view.bounds.size, NO, [[UIScreen mainScreen] scale]);
        [navController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *snapshotView = [[UIImageView alloc] initWithImage:viewImage];
        snapshotView.frame = navController.view.frame;
        [navController.view.superview addSubview:snapshotView];
        if (self.sourceViewController == navController.viewControllers[0]) {
            [navController setViewControllers:@[ self.destinationViewController ] animated:NO];
            UIBarButtonItem *sourceLeftItem = [self.sourceViewController navigationItem].leftBarButtonItem;
            if ([[self.destinationViewController navigationItem].leftBarButtonItems count] == 0 && sourceLeftItem.target != self.sourceViewController) {
                [[self.destinationViewController navigationItem] setLeftBarButtonItem:sourceLeftItem];
            }
        } else {
            [navController popViewControllerAnimated:NO];
            [navController pushViewController:self.destinationViewController animated:NO];
        }
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             snapshotView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [snapshotView removeFromSuperview];
                         }];
    }
}


@end
