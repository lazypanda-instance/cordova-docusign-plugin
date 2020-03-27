//
//  DSDeclineSigningViewController.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/2/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DSDeclineSigningViewController, DSSigningAPIDeclineDetails;

@protocol DSDeclineSigningViewControllerDelegate <NSObject>

- (void)declineSigningViewController:(DSDeclineSigningViewController *)controller declinedSigningWithDetails:(DSSigningAPIDeclineDetails *)details;
- (void)declineSigningViewControllerCancelled:(DSDeclineSigningViewController *)controller;

@end

@interface DSDeclineSigningViewController : UIViewController

@property (nonatomic, weak) id<DSDeclineSigningViewControllerDelegate> delegate;

- (instancetype)initWithDelegate:(id<DSDeclineSigningViewControllerDelegate>)delegate;

@end
