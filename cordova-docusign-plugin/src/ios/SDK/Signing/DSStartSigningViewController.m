//
//  DSStartSigningViewController.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/2/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSStartSigningViewController.h"

#import "DSStoryboardFactory.h"
#import "UIViewController+DSLayoutGuides.h"

#import "DSSigningAPIConsumerDisclosure.h"

#import "DSFinePrintViewController.h"

#import "NSString+DS_ValidEmail.h"

@interface DSStartSigningViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;
@property (weak, nonatomic) IBOutlet UIButton *startSigningButton;
@property (weak, nonatomic) IBOutlet UILabel *recipientNameLabel;

@property (weak, nonatomic) IBOutlet UIView *recipientEmailView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recipientEmailViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextField *recipientEmailTextField;

@property (weak, nonatomic) IBOutlet UIView *consumerDisclosureView;
@property (weak, nonatomic) IBOutlet UILabel *consentLabel;

@property (nonatomic) DSSigningAPIConsumerDisclosure *consumerDisclosureDetails;
@property (nonatomic) NSString *recipientName;
@property (nonatomic) NSString *recipientEmail;
@property (nonatomic) BOOL requestEmail;

@end


// TODO: email input validation, assign email to recipientEmail as it is updated
@implementation DSStartSigningViewController


#pragma mark - Lifecycle


- (instancetype)initWithConsumerDisclosure:(DSSigningAPIConsumerDisclosure *)consumerDisclosure recipientName:(NSString *)recipientName requestEmail:(BOOL)requestEmail delegate:(id<DSStartSigningViewControllerDelegate>)delegate {
    self = [[[DSStoryboardFactory sharedStoryboardFactory] signingStoryboard] instantiateViewControllerWithIdentifier:@"DSStartSigningViewController"];
    if (!self) {
        return nil;
    }
    
    _consumerDisclosureDetails = consumerDisclosure;
    _recipientName = recipientName;
    _requestEmail = requestEmail;
    _delegate = delegate;
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
      
    self.recipientNameLabel.text = self.recipientName;
    self.consentLabel.text = [NSString stringWithFormat:@"By selecting %@, you consent to do business electronically with %@.", self.startSigningButton.titleLabel.text, self.consumerDisclosureDetails.senderName];
    
    if (!self.requestEmail) {
        self.recipientEmailView.hidden = YES;
        self.recipientEmailViewHeightConstraint.constant = 0;
    }
    if ([self.consumerDisclosureDetails.esignAgreement length] == 0) {
        self.consumerDisclosureView.hidden = YES;
    }
    
    self.scrollViewTopConstraint.constant = -[self ds_topLayoutGuideHeight];
}


#pragma mark - User Interaction


- (IBAction)startSigningButtonTapped:(id)sender {
    // TODO: input validation
    self.recipientEmail = self.recipientEmailTextField.text;
    if (self.requestEmail) {
        if ([self.recipientEmail length] == 0) {
            [[[UIAlertView alloc] initWithTitle:@"Please enter your email address" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        } else if (![self.recipientEmail ds_isValidEmail]) {
            [[[UIAlertView alloc] initWithTitle:@"Please enter a valid email address" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
    }
    [self.delegate startSigningViewControllerCompleted:self];
}


- (IBAction)cancelButtonTapped:(id)sender {
    [self.delegate startSigningViewControllerCancelled:self];
}


- (IBAction)consumerDisclosureButtonTapped:(id)sender {
    DSFinePrintViewController *viewController = [[DSFinePrintViewController alloc] initWithHTMLContent:self.consumerDisclosureDetails.esignAgreement];
    [self.navigationController pushViewController:viewController animated:YES];
}


@end
