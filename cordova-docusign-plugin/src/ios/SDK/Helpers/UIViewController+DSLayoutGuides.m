//
//  UIViewController+DSLayoutGuides.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/13/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "UIViewController+DSLayoutGuides.h"

@implementation UIViewController (DSLayoutGuides)

- (CGFloat)ds_topLayoutGuideHeight {
    CGRect navBarFrame = self.navigationController.navigationBar.frame;
    CGFloat navBarHeight = navBarFrame.origin.y + navBarFrame.size.height;
    return MAX(self.topLayoutGuide.length, navBarHeight);
}

@end
