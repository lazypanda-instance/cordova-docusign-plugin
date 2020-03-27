//
//  DSSigningViewController.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 4/28/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DSSigningViewControllerDelegate.h"

extern NSString * const DSSigningViewControllerErrorDomain;

typedef NS_ENUM(NSInteger, DSSigningViewControllerErrorCode) {
    DSSigningViewControllerErrorCodeUnknown = 0,
    DSSigningViewControllerErrorCodeInvalidSigner,
    DSSigningViewControllerErrorCodeTimeout
};

@class DSSessionManager;

@interface DSSigningViewController : UIViewController

@property (nonatomic, readonly) NSString *envelopeID;
@property (nonatomic, readonly) NSString *recipientID;
@property (nonatomic, readonly) DSSessionManager *sessionManager;
@property (nonatomic, readonly, weak) id<DSSigningViewControllerDelegate> delegate;

- (instancetype)initWithEnvelopeID:(NSString *)envelopeID recipientID:(NSString *)recipientID sessionManager:(DSSessionManager *)sessionManager delegate:(id<DSSigningViewControllerDelegate>)delegate;

@end
