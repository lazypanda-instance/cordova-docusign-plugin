//
//  DSCompleteSigningViewController.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/2/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSCompleteSigningViewController.h"

#import "DSStoryboardFactory.h"


@interface DSCompleteSigningViewController ()

@end


@implementation DSCompleteSigningViewController


- (instancetype)initWithDelegate:(id<DSCompleteSigningViewControllerDelegate>)delegate {
    self = [[[DSStoryboardFactory sharedStoryboardFactory] signingStoryboard] instantiateViewControllerWithIdentifier:@"DSCompleteSigningViewController"];
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


#pragma mark - User Interaction


- (IBAction)cancelTapped:(id)sender {
    [self.delegate completeSigningViewControllerCancelled:self];
}


- (IBAction)doneTapped:(id)sender {
    [self.delegate completeSigningViewControllerCompleted:self];
}


@end
