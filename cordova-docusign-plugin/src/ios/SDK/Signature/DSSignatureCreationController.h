//
//  DSSignatureCreationController.h
//  DocuSignIt
//
//  Created by Stephen Parish on 9/26/13.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSSignatureCaptureDelegate.h"

@interface DSSignatureCreationController : UIViewController

@property (nonatomic, weak) id <DSSignatureCaptureDelegate> delegate;
@property (nonatomic) DSSignaturePart signaturePart;
@property (nonatomic) BOOL allowCameraSignatureCapture;

@property (nonatomic) NSString *adoptDisclosureText;

- (void)confirmAdoptSignature:(UIImage *)signatureImage fromView:(id)sender;

@end