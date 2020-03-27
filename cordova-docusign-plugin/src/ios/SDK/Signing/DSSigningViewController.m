//
//  DSSigningViewController.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 4/28/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSSigningViewController.h"

#import "DSStoryboardFactory.h"

#import "DSSessionManager.h"
#import "DSSigningAPIManager.h"
#import "DSSigningAPIAdoptSignatureTabDetails.h"

#import "DSLoginAccount.h"

#import "DSStartSigningViewController.h"
#import "DSSigningAPIConsumerDisclosure.h"

#import "DSDeclineSigningViewController.h"
#import "DSSigningAPIDeclineSigning.h"

#import "DSCompleteSigningViewController.h"

#import "DSEnvelopeDetailsResponse.h"
#import "DSEnvelopeRecipientsResponse.h"
#import "DSEnvelopeRecipient.h"
#import "DSEnvelopeSigner.h"
#import "DSEnvelopeInPersonSigner.h"

#import "DSDrawSignatureController.h"
#import "DSUserSignature.h"

#import "DSRotationForwardingNavigationControllerViewController.h"


NSString * const DSSigningViewControllerErrorDomain = @"DSSigningViewControllerErrorDomain";

typedef NS_ENUM(NSInteger, DSSigningViewControllerViewTag) {
    DSSigningViewControllerViewTagNone = 0,
    DSSigningViewControllerViewTagCancelSigning
};


@interface DSSigningViewController () <DSSigningAPIDelegate, UIActionSheetDelegate, DSStartSigningViewControllerDelegate, DSDeclineSigningViewControllerDelegate, DSCompleteSigningViewControllerDelegate, DSSignatureCaptureDelegate>


@property (nonatomic, weak) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIView *loadingView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishBarButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rotateLeftBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rotateRightBarButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *pageDownBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pageUpBarButton;

- (IBAction)cancelTapped:(id)sender;
- (IBAction)finishTapped:(id)sender;

- (IBAction)rotateLeftTapped:(id)sender;
- (IBAction)rotateRightTapped:(id)sender;

- (IBAction)pageDownTapped:(id)sender;
- (IBAction)pageUpTapped:(id)sender;

@property (nonatomic) NSString *envelopeID;
@property (nonatomic) NSString *recipientID;
@property (nonatomic) DSSessionManager *sessionManager;
@property (nonatomic, weak) id<DSSigningViewControllerDelegate> delegate;

@property (nonatomic) DSSigningAPIManager *signingAPIManager;

@property (nonatomic) BOOL initiatedSigningLoad;

@property (nonatomic) DSEnvelopeRecipientsResponse *recipientsResponse;
@property (nonatomic) DSEnvelopeRecipient *currentSigner;

@property (nonatomic, readonly) NSURL *messageURL;


@end


@implementation DSSigningViewController

@synthesize messageURL = _messageURL;


#pragma mark - Lifecycle


- (instancetype)initWithEnvelopeID:(NSString *)envelopeID recipientID:(NSString *)recipientID sessionManager:(DSSessionManager *)sessionManager delegate:(id<DSSigningViewControllerDelegate>)delegate {
    self = [[[DSStoryboardFactory sharedStoryboardFactory] signingStoryboard] instantiateViewControllerWithIdentifier:@"DSSigningViewController"];
    if (!self) {
        return nil;
    }
    
    _envelopeID = envelopeID;
    _recipientID = recipientID;
    _sessionManager = sessionManager;
    _delegate = delegate;
    self.hidesBottomBarWhenPushed = YES;
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = nil;
    
    self.webView.keyboardDisplayRequiresUserAction = NO;
    
    self.webView.hidden = YES;
    
    self.signingAPIManager = [[DSSigningAPIManager alloc] initWithWebView:self.webView messageURL:[self messageURL] andDelegate:self];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.initiatedSigningLoad) {
        self.initiatedSigningLoad = YES;
        
        [self.sessionManager startEnvelopeDetailsTaskForEnvelopeWithID:self.envelopeID completionHandler:^(DSEnvelopeDetailsResponse *response, NSError *error) {
            if (error) {
                return;
            }
            if (![self isHostedSigning]) {
                self.title = response.emailSubject;
            }
        }];
        [self.sessionManager startEnvelopeRecipientsTaskForEnvelopeWithID:self.envelopeID completionHandler:^(DSEnvelopeRecipientsResponse *response, NSError *error) {
            if (error) {
                [self failedSigningWithError:error];
                return;
            }
            self.recipientsResponse = response;
            for (DSEnvelopeRecipient *recipient in [self.recipientsResponse allSigners]) {
                if ([recipient.userID isEqualToString:self.sessionManager.account.userID] || [recipient.clientUserID length] > 0) {
                    self.currentSigner = recipient;
                    if ([self.recipientID length] == 0) {
                        self.recipientID = self.currentSigner.recipientID;
                    }
                    if ([self isHostedSigning]) {
                        DSEnvelopeInPersonSigner *inPersonSigner = (DSEnvelopeInPersonSigner *)self.currentSigner;
                        NSString *titleString;
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                            titleString = [NSString stringWithFormat:@"Now Signing: %@", inPersonSigner.signerName];
                        } else {
                            titleString = inPersonSigner.signerName;
                        }
                        self.title = titleString;
                    }
                    break;
                }
            }
            if (!self.currentSigner || [self.recipientID length] == 0) {
                [self failedSigningWithError:[NSError errorWithDomain:DSSigningViewControllerErrorDomain code:DSSigningViewControllerErrorCodeInvalidSigner userInfo:nil]];
                return;
            }
            [self.sessionManager startSigningURLTaskForRecipientWithID:self.currentSigner.recipientID userID:self.currentSigner.userID clientUserID:self.currentSigner.clientUserID inEnvelopeWithID:self.envelopeID returnURL:self.messageURL completionHandler:^(NSString *signingURLString, NSError *error) {
                if (error) {
                    [self failedSigningWithError:error];
                    return;
                }
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:signingURLString]]];
            }];
        }];
    }
}


#pragma mark - User Interaction


- (IBAction)cancelTapped:(id)sender {
    NSString *cancelButtonTitle = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? @"Cancel" : nil;
    NSString *destructiveButtonTitle = [self.signingAPIManager canDecline] ? @"Decline to Sign" : nil;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:@"Sign Later", nil];
    actionSheet.tag = DSSigningViewControllerViewTagCancelSigning;
    [actionSheet showFromBarButtonItem:sender animated:YES];
}


- (IBAction)finishTapped:(id)sender {
    if (![self.signingAPIManager canFinish] && ![self.signingAPIManager isFreeform]) {
        [self.signingAPIManager autoNavigate];
        return;
    }
    DSCompleteSigningViewController *controller = [[DSCompleteSigningViewController alloc] initWithDelegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
}


- (IBAction)rotateLeftTapped:(id)sender {
    [self.signingAPIManager rotatePageLeft];
}


- (IBAction)rotateRightTapped:(id)sender {
    [self.signingAPIManager rotatePageRight];
}


- (IBAction)pageDownTapped:(id)sender {
    [self.signingAPIManager scrollToNextPage];
}


- (IBAction)pageUpTapped:(id)sender {
    [self.signingAPIManager scrollToPreviousPage];
}


#pragma mark - Accessors

- (NSURL *)messageURL {
    if (!_messageURL) {
        _messageURL = [[NSURL alloc] initWithString:@"DocuSign://SigningViewController"];
    }
    return _messageURL;
}


#pragma mark -


- (BOOL)isHostedSigning {
    return [self.currentSigner isKindOfClass:[DSEnvelopeInPersonSigner class]];
}

- (void)changeSigningStatus:(DSSigningCompletedStatus)status withObject:(id)object {
    self.loadingView.hidden = NO;
    self.webView.hidden = YES;
    
    if (!self.signingAPIManager.ready) { // If APIManager isn't ready, just dismiss
        [self.delegate signingViewController:self completedWithStatus:status];
        return;
    }
    
    switch (status) {
        case DSSigningCompletedStatusSigned:
            [self.signingAPIManager finishSigning];
            break;
        case DSSigningCompletedStatusDeferred:
            [self.signingAPIManager cancelSigning];
            break;
        case DSSigningCompletedStatusDeclined:
            [self.signingAPIManager declineSigningWithDetails:object];
            break;
    }
}


- (void)failedSigningWithError:(NSError *)error {
    [self.delegate signingViewController:self failedWithError:error];
}


#pragma mark - DSSigningAPIDelegate


- (void)signingIsReady:(DSSigningAPIManager *)signingAPIManager {
    if (![self isHostedSigning]) { // If this is not hosted signing, we will have shown this screen already in -didRequestConsumerDisclosureConsent: if it was necessary
        self.loadingView.hidden = YES;
        self.webView.hidden = NO;
        [self.navigationController setToolbarHidden:NO animated:YES];
        return;
    }
    
    NSString *signerName = self.currentSigner.name;
    DSStartSigningViewController *viewController = [[DSStartSigningViewController alloc] initWithConsumerDisclosure:[self.signingAPIManager consumerDisclosure]
                                                                                                      recipientName:signerName
                                                                                                       requestEmail:YES
                                                                                                           delegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    self.loadingView.hidden = YES;

    [self presentViewController:navController animated:YES completion:^{
        self.webView.hidden = NO;
        [self.navigationController setToolbarHidden:NO animated:NO];
    }];
}


- (void)signingFoundFormFields:(DSSigningAPIManager *)signingAPIManager {
    
}


- (void)signing:(DSSigningAPIManager *)signingAPIManager canFinishChanged:(BOOL)canFinish {
    UIBarButtonItem *rightButton = self.navigationItem.rightBarButtonItem;
    BOOL isFreeform = [self.signingAPIManager isFreeform];
    rightButton.enabled = canFinish || !isFreeform; // Guided signing has next button, so always enabled
    rightButton.title = (canFinish || isFreeform) ? @"Finish" : @"Next";
}


- (void)signing:(DSSigningAPIManager *)signingAPIManager didFailWithErrorMessage:(NSString *)errorMessage {
    NSDictionary *userInfo = errorMessage ? @{ NSLocalizedDescriptionKey : errorMessage } : nil;
    [self failedSigningWithError:[NSError errorWithDomain:DSSigningViewControllerErrorDomain code:DSSigningViewControllerErrorCodeUnknown userInfo:userInfo]];
}


- (void)signing:(DSSigningAPIManager *)signingAPIManager didRequestConsumerDisclosureConsent:(DSSigningAPIConsumerDisclosure *)consumerDisclosure {
    
    if ([self isHostedSigning]) { // We will ignore here, because we ALWAYS show for hosted signing is -signingIsReady
        return;
    }
    
    NSString *signerName = self.currentSigner.name;
    DSStartSigningViewController *viewController = [[DSStartSigningViewController alloc] initWithConsumerDisclosure:consumerDisclosure
                                                                                                      recipientName:signerName
                                                                                                       requestEmail:NO
                                                                                                           delegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
}


- (void)signing:(DSSigningAPIManager *)signingAPIManager didRequestDecline:(DSSigningAPIDeclineOptions *)declineOptions {
    
}


- (void)signing:(DSSigningAPIManager *)signingAPIManager didRequestCarbonCopies:(DSSigningAPIAddCCRecipients *)ccRecipientOptions {
    
}


- (void)signing:(DSSigningAPIManager *)signingAPIManager didRequestSignature:(DSSigningAPIAdoptSignatureTabDetails *)adoptSignatureOptions {
    DSDrawSignatureController *drawSignature = [[[DSStoryboardFactory sharedStoryboardFactory] signatureStoryboard] instantiateInitialViewController];
    drawSignature.signaturePart = adoptSignatureOptions.type == DSSigningAPITabSignHere ? DSSignaturePartSignature : DSSignaturePartInitials;
    drawSignature.delegate = self;
    drawSignature.allowCameraSignatureCapture = YES;
    UINavigationController *navigationController = [[DSRotationForwardingNavigationControllerViewController alloc] initWithRootViewController:drawSignature];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}


- (void)signingDidTimeout:(DSSigningAPIManager *)signingAPIManager {
    [self failedSigningWithError:[NSError errorWithDomain:DSSigningViewControllerErrorDomain code:DSSigningViewControllerErrorCodeTimeout userInfo:@{ NSLocalizedDescriptionKey : @"Your signing session has timed out." }]];
}


- (void)signingDidDecline:(DSSigningAPIManager *)signingAPIManager {
    [self.delegate signingViewController:self completedWithStatus:DSSigningCompletedStatusDeclined];
}


- (void)signingDidCancel:(DSSigningAPIManager *)signingAPIManager {
    [self.delegate signingViewController:self completedWithStatus:DSSigningCompletedStatusDeferred];
}


- (void)signingDidViewEnvelope:(DSSigningAPIManager *)signingAPIManager {
    
}


- (void)signingDidComplete:(DSSigningAPIManager *)signingAPIManager {
    [self.delegate signingViewController:self completedWithStatus:DSSigningCompletedStatusSigned];
}


#pragma - UIWebViewDelegate


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.loadingView.hidden = NO;
    self.webView.hidden = YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.loadingView.hidden = YES;
    self.webView.hidden = NO;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    BOOL frameLoadInterrupted = (error.code == 102 && [error.domain isEqualToString:@"WebKitErrorDomain"]);
    if (error.code != NSURLErrorCancelled && !frameLoadInterrupted) { // Ignore these errors. They happen during normal interaction with signing
        [self failedSigningWithError:error];
    }
}


#pragma mark - DSStartSigningViewControllerDelegate


- (void)startSigningViewControllerCompleted:(DSStartSigningViewController *)controller {
    self.signingAPIManager.inPersonSignerEmail = controller.recipientEmail;
    [self.signingAPIManager acceptConsumerDisclosure];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)startSigningViewControllerCancelled:(DSStartSigningViewController *)controller {
    // TODO: this counts as a decline to sign?
    [self changeSigningStatus:DSSigningCompletedStatusDeferred withObject:nil];
}


#pragma mark - DSDeclineSigningViewControllerDelegate


- (void)declineSigningViewController:(DSDeclineSigningViewController *)controller declinedSigningWithDetails:(DSSigningAPIDeclineDetails *)details {
    [self changeSigningStatus:DSSigningCompletedStatusDeclined withObject:details];
}


- (void)declineSigningViewControllerCancelled:(DSDeclineSigningViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - DSCompleteSigningViewControllerDelegate


- (void)completeSigningViewControllerCompleted:(DSCompleteSigningViewController *)viewController {
    [self changeSigningStatus:DSSigningCompletedStatusSigned withObject:nil];
}


- (void)completeSigningViewControllerCancelled:(DSCompleteSigningViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == DSSigningViewControllerViewTagCancelSigning) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            // TODO: show decline modal
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self changeSigningStatus:DSSigningCompletedStatusDeferred withObject:nil];
        }
    }
}


#pragma mark - DSSignatureCaptureDelegate


- (void)signatureCaptureCanceled:(UIViewController *)capController {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.signingAPIManager cancelAdoptSignatureOrInitials];
}


- (void)signatureCapture:(UIViewController *)capController didFinishWithInitials:(UIImage *)initials {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.sessionManager startRecipientSignatureCreateTaskForRecipientID:self.currentSigner.recipientID inEnvelopeWithID:self.envelopeID image:initials signaturePart:DSSignaturePartInitials completionHandler:^(NSError *error) {
        if (error) {
            [self handleSignatureError:error];
            return;
        }
        [self.sessionManager startRecipientSignatureDetailsTaskForRecipientID:self.currentSigner.recipientID inEnvelopeWithID:self.envelopeID completionHandler:^(DSUserSignature *response, NSError *error) {
            if (error) {
                [self handleSignatureError:error];
                return;
            }
            [self.signingAPIManager adoptInitials:response.initials150ImageID];
        }];
    }];
}


- (void)signatureCapture:(UIViewController *)capController didFinishWithSignature:(UIImage *)signature {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.sessionManager startRecipientSignatureCreateTaskForRecipientID:self.currentSigner.recipientID inEnvelopeWithID:self.envelopeID image:signature signaturePart:DSSignaturePartSignature completionHandler:^(NSError *error) {
        if (error) {
            [self handleSignatureError:error];
            return;
        }
        [self.sessionManager startRecipientSignatureDetailsTaskForRecipientID:self.currentSigner.recipientID inEnvelopeWithID:self.envelopeID completionHandler:^(DSUserSignature *response, NSError *error) {
            if (error) {
                [self handleSignatureError:error];
                return;
            }
            [self.signingAPIManager adoptSignature:response.signature150ImageID];
        }];
    }];
}


- (UIInterfaceOrientation)currentInterfaceOrientation {
    return self.interfaceOrientation;
}


#pragma mark - Signature Errors


- (void)handleSignatureError:(NSError *)error {
    [self.signingAPIManager cancelAdoptSignatureOrInitials];
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Adopting Signature", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
}


@end
