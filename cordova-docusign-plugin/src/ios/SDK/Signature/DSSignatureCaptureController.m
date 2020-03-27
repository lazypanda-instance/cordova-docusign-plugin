//
//  SignatureCaptureController.m
//  DocuSignIt
//
//  Created by Deyton Sehn on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DSSignatureCaptureController.h"
#import "UIImage+Resize.h"
#import "UIImage+SignatureCleanup.h"
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import "DSDrawSignatureController.h"

typedef enum {
    CaptureModeCamera,
    CaptureModeEdit
} CaptureMode;

@interface DSSignatureCaptureController ()

@property (nonatomic) CGFloat whiteLevel;
@property (nonatomic, strong) UIImage *savedCapture;
@property (nonatomic, strong) AVCaptureStillImageOutput *capturedImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, weak) IBOutlet UIView *cameraPreviewView;
@property (nonatomic, weak) IBOutlet UIImageView *editPreviewImageView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UIButton *drawSignatureButton;

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *cameraControls;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *editControls;

- (IBAction)contrastChanged:(UISlider *)sender;
- (IBAction)captureTapped:(id)sender;
- (IBAction)retakeTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;

@end

@implementation DSSignatureCaptureController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPreset640x480;
    
	self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.cameraPreviewView.bounds;
    [self.cameraPreviewView.layer insertSublayer:self.previewLayer atIndex:0];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device isFlashAvailable]) {
        [device lockForConfiguration:nil];
        device.flashMode = AVCaptureFlashModeAuto;
        [device unlockForConfiguration];
    }
    
	NSError *error = nil;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!input) {
// TODO: error?
	}
    
    [session addInput:input];
    
    self.capturedImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.capturedImageOutput setOutputSettings:outputSettings];
    [session addOutput:self.capturedImageOutput];
    
    [session startRunning];
    
    self.whiteLevel = 109.65;
    
    NSString *drawText = [NSString stringWithFormat:NSLocalizedString(@"Go back to draw %@", nil),
                              self.signaturePart == DSSignaturePartSignature ? NSLocalizedString(@"signature", nil) : NSLocalizedString(@"initials", nil)];
    [self.drawSignatureButton setTitle:drawText forState:UIControlStateNormal];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationController.navigationBar.translucent = YES;
    }
    
    if (self.signaturePart == DSSignaturePartSignature) {
        self.title = NSLocalizedString(@"Capture Your Signature", nil);
    } else {
        self.title = NSLocalizedString(@"Capture Your Initials", nil);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setCaptureMode:CaptureModeCamera];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        AVCaptureConnection *videoConnection = nil;
        for (AVCaptureConnection *connection in self.capturedImageOutput.connections) {
            for (AVCaptureInputPort *port in [connection inputPorts]) {
                if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                    videoConnection = connection;
                    break;
                }
            }
            if (videoConnection) { 
                break; 
            }
        }
        
        videoConnection.videoOrientation = (AVCaptureVideoOrientation)[self.delegate currentInterfaceOrientation];
        CGFloat angle;
        switch ([self.delegate currentInterfaceOrientation]) {
            case UIInterfaceOrientationPortrait:
                angle = 0.0;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                angle = M_PI/2.0;
                break;
            case UIInterfaceOrientationLandscapeRight:
                angle = -M_PI/2.0;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                angle = M_PI;
                break;
            default:
                break;
        }
        self.previewLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeRotation(angle));
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.frame = self.cameraPreviewView.bounds;
    } else {
        AVCaptureConnection *videoConnection = nil;
        for (AVCaptureConnection *connection in self.capturedImageOutput.connections) {
            for (AVCaptureInputPort *port in [connection inputPorts]) {
                if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                    videoConnection = connection;
                    break;
                }
            }
            if (videoConnection) { 
                break; 
            }
        }
        videoConnection.videoOrientation = (AVCaptureVideoOrientation)[self.delegate currentInterfaceOrientation];
        CGFloat angle;
        angle = -M_PI/2.0;
        self.previewLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeRotation(angle));
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.frame = self.cameraPreviewView.bounds;
    }
}

#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ([self supportedInterfaceOrientations] & (1 << interfaceOrientation)) != 0;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskLandscape;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }
    CGFloat angle;
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        angle = -M_PI/2;
    } else {
        angle = M_PI/2;
    }
    [self.previewLayer setAffineTransform:CGAffineTransformMakeRotation(angle)];
}

#pragma mark - User Interaction

- (IBAction)captureTapped:(id)sender {
    [self setCaptureMode:CaptureModeEdit];
    
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in self.capturedImageOutput.connections) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
            break;
        }
	}
    videoConnection.videoOrientation = (AVCaptureVideoOrientation)[self.delegate currentInterfaceOrientation];
    
    //__weak typeof(self) weakSelf = self;
    __weak DSSignatureCaptureController *weakSelf = self;
	[self.capturedImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        if (imageSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            UIImageOrientation imageOrientation;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                imageOrientation = UIImageOrientationUp;
            } else {
                if (weakSelf.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                    imageOrientation = UIImageOrientationDown;
                } else {
                    imageOrientation = UIImageOrientationUp;
                }
            }
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                image = [[UIImage alloc] initWithCGImage: image.CGImage
                                                   scale: 1.0
                                             orientation: imageOrientation];
            }
            weakSelf.savedCapture = [image imageCroppedToSize:weakSelf.editPreviewImageView.frame.size];
            weakSelf.editPreviewImageView.image = [weakSelf.savedCapture imageMaskedWithWhiteLevel:weakSelf.whiteLevel];
        }
    }];
}

- (IBAction)retakeTapped:(id)sender {
    [self setCaptureMode:CaptureModeCamera];
}

- (IBAction)contrastChanged:(UISlider *)sender {
    CGFloat newWhiteLevel = floor(sender.value * 255);
    if (self.whiteLevel != newWhiteLevel) {
        self.whiteLevel = newWhiteLevel;
        self.editPreviewImageView.image = [self.savedCapture imageMaskedWithWhiteLevel:newWhiteLevel];
    }
}

- (IBAction)doneTapped:(id)sender {
    if (self.editPreviewImageView.image) {
        [self confirmAdoptSignature:[self.editPreviewImageView.image imageWithTransparentCropped] fromView:sender];
    }
}

- (IBAction)cancelTapped:(id)sender {
    [self.delegate signatureCaptureCanceled:self];
}

#pragma mark - Property Overrides

- (void)setWhiteLevel:(CGFloat)whiteLevel {
    if (whiteLevel != self.whiteLevel && whiteLevel >= 0.0 && whiteLevel <= 255.0) {
        _whiteLevel = whiteLevel;
    }
}

#pragma mark - Helpers

- (void)setCaptureMode:(CaptureMode)captureMode {
    for (UIView *cameraView in self.cameraControls) {
        cameraView.hidden = captureMode != CaptureModeCamera;
    }
    
    for (UIView *editView in self.editControls) {
        editView.hidden = captureMode != CaptureModeEdit;
    }
    
    self.doneButton.enabled = captureMode == CaptureModeEdit;
    
    self.drawSignatureButton.hidden = !self.allowCameraSignatureCapture;
}

@end
