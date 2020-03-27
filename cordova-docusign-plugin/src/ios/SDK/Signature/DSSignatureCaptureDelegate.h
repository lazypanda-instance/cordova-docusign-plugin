//
//  DSSignatureCaptureDelegate.h
//  DocuSignIt
//
//  Created by Deyton Sehn on 7/20/12.
//  Copyright (c) 2012 DocuSign, Inc. All rights reserved.
//

#import "DSSignaturePart.h"

@protocol DSSignatureCaptureDelegate <NSObject>

@required
- (void)signatureCapture:(UIViewController*)capController didFinishWithSignature:(UIImage *)signature;
- (void)signatureCapture:(UIViewController*)capController didFinishWithInitials:(UIImage *)initials;
- (void)signatureCaptureCanceled:(UIViewController*)capController;
- (UIInterfaceOrientation)currentInterfaceOrientation;

@end