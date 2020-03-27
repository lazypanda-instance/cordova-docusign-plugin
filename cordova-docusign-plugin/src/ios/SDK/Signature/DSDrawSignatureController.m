//
//  DSDrawSignatureController.m
//  DocuSignIt
//
//  Created by Arlo Armstrong on 4/10/12.
//  Copyright (c) 2012 DocuSign, Inc. All rights reserved.
//

#import "DSDrawSignatureController.h"
#import "DSDrawSignatureView.h"
#import "UIImage+SignatureCleanup.h"
#import "DSSignatureCaptureController.h"

#pragma mark Private interface

@interface DSDrawSignatureController ()

#pragma mark - Private properties

@property (nonatomic, weak) IBOutlet DSDrawSignatureView *signatureView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *adoptButton;
@property (nonatomic, weak) IBOutlet UIButton *markerButton;
@property (nonatomic, weak) IBOutlet UIButton *penButton;
@property (nonatomic, weak) IBOutlet UIButton *clearButton;
@property (nonatomic, weak) IBOutlet UIButton *blackButton;
@property (nonatomic, weak) IBOutlet UIButton *blueButton;
@property (nonatomic, weak) IBOutlet UIButton *redButton;
@property (nonatomic, weak) IBOutlet UIButton *captureSignatureButton;
@property (nonatomic, weak) IBOutlet UIView *penContainerView;
@property (nonatomic, weak) IBOutlet UIView *colorContainerView;

@property (nonatomic, strong) UIImage *signatureImage;
@property (nonatomic, strong) UIImage *initialsImage;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *cameraButtonHeightConstraint;

#pragma mark - Private methods

- (void)prepareNavigationForSignature:(BOOL)animated;

- (IBAction)clearTapped:(id)sender;
- (IBAction)adoptButtonTapped:(id)sender;
- (IBAction)colorChanged:(UISegmentedControl *)control;
- (IBAction)penTapped:(id)sender;
- (IBAction)markerTapped:(id)sender;
- (IBAction)closeTapped:(id)sender;
- (IBAction)blackButtonTapped:(id)sender;
- (IBAction)blueButtonTapped:(id)sender;
- (IBAction)redButtonTapped:(id)sender;

@end

#pragma mark - Implementation

@implementation DSDrawSignatureController

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:@"empty"]) {
        self.navigationItem.rightBarButtonItem.enabled = ![[change objectForKey:NSKeyValueChangeNewKey] boolValue];
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
    
    
}

- (void)dealloc {
    [self.signatureView removeObserver:self forKeyPath:@"empty"];
}

#pragma mark - Lifecycle

- (void)styleContainerView:(UIView *)containerView{
    containerView.layer.masksToBounds = YES;
    containerView.layer.cornerRadius = 5;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self styleContainerView:self.penContainerView];
    [self styleContainerView:self.colorContainerView];
    
    [self.signatureView addObserver:self
                         forKeyPath:@"empty" 
                            options:NSKeyValueObservingOptionNew
                            context:NULL];
    if (!self.navigationItem) {
        [NSException raise:@"IllegalOperationError" format:@"DSDrawSignatureController must be used within a navigation controller."];
    }
    
    self.penButton.selected = YES;
    self.blackButton.selected = YES;
    self.signatureView.empty = YES;
    
    NSString *captureText = [NSString stringWithFormat:NSLocalizedString(@"Use camera to capture paper %@", nil),
                              self.signaturePart == DSSignaturePartSignature ? NSLocalizedString(@"signature", nil) : NSLocalizedString(@"initials", nil)];
    [self.captureSignatureButton setTitle:captureText forState:UIControlStateNormal];
    
    self.allowCameraSignatureCapture = self.allowCameraSignatureCapture && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!self.allowCameraSignatureCapture) {
        self.captureSignatureButton.hidden = !self.allowCameraSignatureCapture;
        self.cameraButtonHeightConstraint.constant = 0;
    }
    
    self.adoptDisclosureText = NSLocalizedString(@"By tapping Adopt, you agree that the signature or initials will be the electronic representation of your signature or initials for all purposes when you (or your agent) use them on documents, including legally binding contracts - just the same as a pen-and-paper signature or initial.", nil);
    
    [self prepareNavigationForSignature:NO];
}

#pragma mark - Orientation

- (NSUInteger)supportedInterfaceOrientations {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

#pragma mark - Private methods

- (void)prepareNavigationForSignature:(BOOL)animated {
    if (self.signaturePart == DSSignaturePartSignature) {
        self.title = NSLocalizedString(@"Draw Your Signature", nil);
    } else {
        self.title = NSLocalizedString(@"Draw Your Initials", nil);
    }    
}

#pragma mark - User interaction

- (IBAction)adoptButtonTapped:(id)sender {
    [self confirmAdoptSignature:[[self.signatureView getImage] imageWithWhiteCropped] fromView:sender];
}

- (IBAction)colorChanged:(UISegmentedControl *)control {
    switch (control.selectedSegmentIndex) {
        case 0:
            self.signatureView.lineColor = [UIColor blackColor];
            break;
        case 1:
            self.signatureView.lineColor = [UIColor blueColor];
            break;
        case 2:
            self.signatureView.lineColor = [UIColor redColor];
            break;
    }
}

- (IBAction)penTapped:(id)sender {
    self.markerButton.selected = NO;
    self.penButton.selected = YES;
    [self.signatureView setFixedLineWidth:NO];
}

- (IBAction)markerTapped:(id)sender {
    self.markerButton.selected = YES;
    self.penButton.selected = NO;
    [self.signatureView setFixedLineWidth:YES];
}

- (IBAction)closeTapped:(id)sender {
    [self.delegate signatureCaptureCanceled:self];
}

- (IBAction)blackButtonTapped:(id)sender {
    self.blackButton.selected = YES;
    self.blueButton.selected = NO;
    self.redButton.selected = NO;
    self.signatureView.lineColor = [UIColor blackColor];
}

- (IBAction)blueButtonTapped:(id)sender {
    self.blackButton.selected = NO;
    self.blueButton.selected = YES;
    self.redButton.selected = NO;
    self.signatureView.lineColor = [UIColor blueColor];
}

- (IBAction)redButtonTapped:(id)sender {
    self.blackButton.selected = NO;
    self.blueButton.selected = NO;
    self.redButton.selected = YES;
    self.signatureView.lineColor = [UIColor redColor];
}

- (IBAction)clearTapped:(id)sender {
    [self.signatureView clear];
}

@end
