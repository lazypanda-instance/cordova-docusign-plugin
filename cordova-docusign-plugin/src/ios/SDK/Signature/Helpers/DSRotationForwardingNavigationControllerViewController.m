//
//  DSRotationForwardingNavigationControllerViewController.m
//  DocuSign iOS SDK
//
//  Created by Deyton Sehn on 5/9/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSRotationForwardingNavigationControllerViewController.h"

@implementation DSRotationForwardingNavigationControllerViewController

- (NSUInteger)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

@end
