//
//  DSStartSigningViewController.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/2/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DSStartSigningViewController, DSSigningAPIConsumerDisclosure;

@protocol DSStartSigningViewControllerDelegate <NSObject>

- (void)startSigningViewControllerCompleted:(DSStartSigningViewController *)controller;
- (void)startSigningViewControllerCancelled:(DSStartSigningViewController *)controller;

@end

@interface DSStartSigningViewController : UIViewController

@property (nonatomic, readonly) DSSigningAPIConsumerDisclosure *consumerDisclosureDetails;
@property (nonatomic, readonly) NSString *recipientName;
@property (nonatomic, readonly) NSString *recipientEmail;
@property (nonatomic, readonly) BOOL requestEmail;
@property (nonatomic, weak) id<DSStartSigningViewControllerDelegate> delegate;

- (instancetype)initWithConsumerDisclosure:(DSSigningAPIConsumerDisclosure *)consumerDisclosureDetails recipientName:(NSString *)recipientName requestEmail:(BOOL)requestEmail delegate:(id<DSStartSigningViewControllerDelegate>)delegate;

@end
