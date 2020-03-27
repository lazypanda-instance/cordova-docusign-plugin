//
//  DSDeclineSigningViewController.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/2/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSDeclineSigningViewController.h"

#import "DSStoryboardFactory.h"


@interface DSDeclineSigningViewController ()

@end


@implementation DSDeclineSigningViewController


- (instancetype)initWithDelegate:(id<DSDeclineSigningViewControllerDelegate>)delegate {
    self = [[[DSStoryboardFactory sharedStoryboardFactory] signingStoryboard] instantiateViewControllerWithIdentifier:@"DSDeclineSigningViewController"];
    if (!self) {
        return nil;
    }
    
    _delegate = delegate;
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
