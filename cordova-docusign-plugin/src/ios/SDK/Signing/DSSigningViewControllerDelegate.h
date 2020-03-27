//
//  DSSigningViewControllerDelegate.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 4/29/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DSSigningCompletedStatus.h"

@class DSSigningViewController;

@protocol DSSigningViewControllerDelegate <NSObject>

- (void)signingViewController:(DSSigningViewController *)signingViewController completedWithStatus:(DSSigningCompletedStatus)status;
- (void)signingViewController:(DSSigningViewController *)signingViewController failedWithError:(NSError *)error;

@end
