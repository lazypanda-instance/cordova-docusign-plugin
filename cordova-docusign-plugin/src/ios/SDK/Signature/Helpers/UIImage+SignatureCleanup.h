//
//  UIImage+SignatureCleanup.h
//  DocuSignIt
//
//  Created by Arlo Armstrong on 4/12/12.
//  Copyright (c) 2012 DocuSign, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SignatureCleanup)

- (UIImage *)imageWithWhiteCropped;
- (UIImage *)imageWithTransparentCropped;
- (UIImage *)imageMaskedWithWhiteLevel:(CGFloat)whiteLevel;
- (UIImage *)imageCroppedToSize:(CGSize)previewSize;
@end
