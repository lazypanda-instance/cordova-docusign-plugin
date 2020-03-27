//
//  DSSigningAPIManager.h
//  DocuSignIt
//
//  Created by Stephen Parish on 12/12/13.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "DSSigningAPITab.h"

@class DSSigningAPIConsumerDisclosure, DSSigningAPIDeclineSigning;

@class DSSigningAPIManager, DSSigningAPIDeclineOptions, DSSigningAPIAdoptSignatureTabDetails, DSSigningAPIAddCCRecipients;

@protocol DSSigningAPIDelegate <UIWebViewDelegate>

- (void)signingIsReady:(DSSigningAPIManager *)signingAPIManager;

- (void)signingFoundFormFields:(DSSigningAPIManager *)signingAPIManager;

- (void)signing:(DSSigningAPIManager *)signingAPIManager canFinishChanged:(BOOL)canFinish;

- (void)signing:(DSSigningAPIManager *)signingAPIManager didFailWithErrorMessage:(NSString *)errorMessage;

- (void)signing:(DSSigningAPIManager *)signingAPIManager didRequestConsumerDisclosureConsent:(DSSigningAPIConsumerDisclosure *)consumerDisclosure;

- (void)signing:(DSSigningAPIManager *)signingAPIManager didRequestDecline:(DSSigningAPIDeclineOptions *)declineOptions;

- (void)signing:(DSSigningAPIManager *)signingAPIManager didRequestSignature:(DSSigningAPIAdoptSignatureTabDetails *)adoptSignatureOptions;

- (void)signing:(DSSigningAPIManager *)signingAPIManager didRequestCarbonCopies:(DSSigningAPIAddCCRecipients *)ccRecipientOptions;

#pragma mark -

- (void)signingDidTimeout:(DSSigningAPIManager *)signingAPIManager;

- (void)signingDidDecline:(DSSigningAPIManager *)signingAPIManager;

- (void)signingDidCancel:(DSSigningAPIManager *)signingAPIManager;

- (void)signingDidViewEnvelope:(DSSigningAPIManager *)signingAPIManager;

- (void)signingDidComplete:(DSSigningAPIManager *)signingAPIManager;

@end

@interface DSSigningAPIManager : NSObject

@property (nonatomic, readonly, getter = isReady) BOOL ready;

@property (nonatomic) BOOL canFinish;

/**
 *  Load a signing session in DSSigningAPIManager, any current sessions will cancel and save the session for later.
 */
- (instancetype)initWithWebView:(UIWebView *)webView messageURL:(NSURL *)messageURL andDelegate:(id<DSSigningAPIDelegate>)delegate;

@property (nonatomic, readonly) NSURL *messageURL;

/**
 *  Object complying with DSSigningAPIManagerDelegate that will receive signing session event notifications
 */
@property (nonatomic, weak) id<DSSigningAPIDelegate> delegate;

#pragma mark - Signing Lifecycle

/**
 *  Saves the current envelope state. User is able to continue signing.
 */
- (void)saveSigning;

/**
 *  Saves the current envelope state and close it. User must reopen envelope to continue signing.
 */
- (void)cancelSigning;

/**
 *  Finishes signing the current envelope. Returns YES if successful, NO otherwise.
 *
 *  @return YES if signing finished successfully, NO otherwise
 */
- (BOOL)finishSigning;

#pragma mark - Carbon Copy Recipients

/**
 *  Returns the default information to display when prompting the user to add carbon copy recipients. nil means unable to add recipients.
 *
 *  @return the default information to display when prompting the user to add carbon copy recipients
 */
- (DSSigningAPIAddCCRecipients *)carbonCopyRecipientAddingOptions;

/**
 *  Adds carbon copy recipients to the envelope. Used to
 *
 *  @param carbonCopies includes both the recipient details and the email which should be sent.
 *
 *  @see -carbonCopyRecipientAddingOptions
 */
- (void)addCarbonCopyRecipients:(DSSigningAPIAddCCRecipients *)carbonCopyRecipients;

#pragma mark - Consumer Disclosure

/**
 *  Notifies the signing experince that the user has agreed to the consumer disclosure.
 */
- (void)acceptConsumerDisclosure;

/**
 *  Returns the Electronic Record and Signature Disclosure the signer must agree to in order to view the envelope. If nil, there is no Electronic Record and Signature Disclosure to agree to.
 *
 *  @return the Electronic Record and Signature Disclosure the signer must agree to
 */
- (DSSigningAPIConsumerDisclosure *)consumerDisclosure;

#pragma mark - Decline

/**
 *  Returns YES if current signer is allowed to decline the envelope.
 *
 *  @return YES if current signer is allowed to decline the envelope
 */
- (BOOL)canDecline;

/**
 *  Return the options available to decline signing an envelope. If no options are returned, decline is not allowed.
 *
 *  @return the options available to decline signing an envelope
 */
- (DSSigningAPIDeclineOptions *)declineOptions;

/**
 *  Decline to sign an envelope, and end the signing ceremony.
 *
 *  @param reason   The reason the user is declining to sign the envelope.
 *  @param withdraw YES if the user wishes to withdraw their consent to do business electronically.
 */
- (void)declineSigningWithDetails:(DSSigningAPIDeclineSigning *)details;

#pragma mark - Signature

/**
 *  Notify Signing that signature adoption is finished.
 *
 *  @param signatureImageId a guid identifiing the signature
 */
- (void)adoptSignature:(NSString *)signatureImageId;

/**
 *  Notify Signing that initials adoption is finished.
 *
 *  @param initialsImageId a guid identifiing the initials
 */
- (void)adoptInitials:(NSString *)initialsImageId;

/**
 *  Cancels adoption of signature/initials.
 */
- (void)cancelAdoptSignatureOrInitials;

#pragma mark - Navigate Document

/**
 *  Go to the next tab or page.
 */
- (void)autoNavigate;

/**
 *  Scrolls the document to the top of the next page with animation.
 */
- (void)scrollToNextPage;

/**
 *  Scrolls the document to the top of the previous page with animation.
 */
- (void)scrollToPreviousPage;

/**
 *  Scrolls the document to the top of the requested page number with animation.
 */
- (void)scrollToPage:(NSInteger)page;

/**
 *  The total pages in the document being signed.
 *
 *  @return The number of pages.
 */
- (NSInteger)pageCount;

/**
 *  Returns the current page number.
 *
 *  @return the current page number
 */
- (NSInteger)currentPageNumber;

#pragma mark - Rotate Page

/**
 *  Rotates current page clockwise
 */
- (void)rotatePageRight;

/**
 *  Rotates current page counter-clockwise
 */
- (void)rotatePageLeft;

#pragma mark - Hosted Signing

/**
 *  Used to store the users email such that it is available when the relevant message is received from the signing experience.
 */
@property (nonatomic, strong) NSString *inPersonSignerEmail;

#pragma mark - Tags

/**
 *  Select a tab type that should be applied to a freeform envelope the next time the user taps the page.
 *
 *  If no tab type is passed, no tab will be applied next time user taps the page.
 */
@property (nonatomic) DSSigningAPITab selectedFreeformTab;

/**
 *  Returns YES if tabs can be selected and applied by the current signer.
 *
 *  @return YES if tabs can be selected and applied by the current signer
 */
- (BOOL)isFreeform;

/**
 *  Returns information describing the tab which caused the user to adopt their signature.
 *
 *  @return information describing the tab which caused the user to adopt their signature
 */
- (DSSigningAPIAdoptSignatureTabDetails *)currentSignatureTabDetails;

/**
 *  If YES, converts pdf fields in the document to tags. Otherwise ???
 *
 *  @param apply YES if pdf fields in the document should be converted to tags
 */
- (void)applyFormFields:(BOOL)apply;

@end