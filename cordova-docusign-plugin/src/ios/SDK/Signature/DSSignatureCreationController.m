//
//  DSSignatureCreationController.m
//  DocuSignIt
//
//  Created by Stephen Parish on 9/26/13.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSSignatureCreationController.h"

@interface DSSignatureCreationController () <UIActionSheetDelegate>

@property (nonatomic) UIImage *image;

@end

@implementation DSSignatureCreationController

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *dest;
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        dest = [segue.destinationViewController topViewController];
    } else {
        dest = segue.destinationViewController;
    }
    
    if ([dest isKindOfClass:[DSSignatureCreationController class]]) {
        DSSignatureCreationController *controller = (DSSignatureCreationController *)dest;
        controller.delegate = self.delegate;
        controller.signaturePart = self.signaturePart;
        controller.allowCameraSignatureCapture = self.allowCameraSignatureCapture;
        controller.adoptDisclosureText = self.adoptDisclosureText;
    }
}

#pragma mark - Property Overrides

- (CGSize)preferredContentSize {
    return CGSizeMake(540, 300);
}

#pragma mark - Helpers

- (void)confirmAdoptSignature:(UIImage *)signatureImage fromView:(id)sender {
    self.image = signatureImage;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.adoptDisclosureText
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Adopt", nil), nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        if (self.signaturePart == DSSignaturePartSignature) {
            [self.delegate signatureCapture:self didFinishWithSignature:self.image];
        } else {
            [self.delegate signatureCapture:self didFinishWithInitials:self.image];
        }
    }
}

@end
