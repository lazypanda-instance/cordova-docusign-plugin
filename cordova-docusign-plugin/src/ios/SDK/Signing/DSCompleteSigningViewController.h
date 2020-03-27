//
//  DSCompleteSigningViewController.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/2/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DSCompleteSigningViewController;

@protocol DSCompleteSigningViewControllerDelegate <NSObject>

- (void)completeSigningViewControllerCompleted:(DSCompleteSigningViewController *)viewController;
- (void)completeSigningViewControllerCancelled:(DSCompleteSigningViewController *)viewController;

@end

@interface DSCompleteSigningViewController : UIViewController

@property (nonatomic, weak) id<DSCompleteSigningViewControllerDelegate> delegate;

- (instancetype)initWithDelegate:(id<DSCompleteSigningViewControllerDelegate>)delegate;

@end
