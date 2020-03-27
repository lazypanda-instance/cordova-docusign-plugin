//
//  UIImage+SignatureCleanup.m
//  DocuSignIt
//
//  Created by Arlo Armstrong on 4/12/12.
//  Copyright (c) 2012 DocuSign, Inc. All rights reserved.
//

#import "UIImage+SignatureCleanup.h"
#import "UIImage+Resize.h"

NSRange MakeRange(NSInteger* sumArray, NSInteger length) {
    NSInteger cropStart = 0;
    NSInteger cropEnd = 0;
    NSInteger total = 0;
    
    for (NSInteger i = 0; i < length; i++) {
        if (total != 0 && cropStart == 0) {
            cropStart = i - 1;
        }
        NSInteger newTotal = total + sumArray[i];
        if (newTotal != total) {
            cropEnd = i;
        }
        total = newTotal;
    }
    return NSMakeRange(cropStart, cropEnd-cropStart+1);
}

@implementation UIImage (SignatureCleanup)

- (UIImage *)imageWithCropping:(BOOL)transparent {
    NSData *pngData = UIImagePNGRepresentation(self);
    UIImage *tempImage = [UIImage imageWithData:pngData];
    CGImageRef imageRefWithTransparency = [tempImage CGImage];
    // Traverse the bytes and trim excess transparency
    CGDataProviderRef provider = CGImageGetDataProvider(imageRefWithTransparency);
    NSData* data = (__bridge_transfer NSData *)CGDataProviderCopyData(provider);
    const uint8_t* newBytes = [data bytes];
    size_t bpr = CGImageGetBytesPerRow(imageRefWithTransparency);
    size_t bpp = CGImageGetBitsPerPixel(imageRefWithTransparency);
    size_t bpc = CGImageGetBitsPerComponent(imageRefWithTransparency);
    size_t bytes_per_pixel = bpp / bpc;
    size_t width = CGImageGetWidth(imageRefWithTransparency);
    size_t height = CGImageGetHeight(imageRefWithTransparency);
    
    NSInteger columnTotals[width];
    NSInteger rowTotals[height];
    for (NSInteger i = 0; i < width; i++) {
        columnTotals[i] = 0;
    }
    for (NSInteger i = 0; i < height; i++) {
        rowTotals[i] = 0;
    }
    
    for (size_t curRow = 0; curRow < height; curRow++) {
        for (size_t curCol= 0; curCol < width; curCol++) {
            const uint8_t* pixel =
            &newBytes[curRow * bpr + curCol * bytes_per_pixel];
            
            if (transparent) {
                if (pixel[3] != 0) {
                    columnTotals[curCol] += 1;
                    rowTotals[curRow] += 1;
                } 
            } else {
                if (pixel[0] != 255 || pixel[1] != 255 || pixel[2] != 255) {
                    columnTotals[curCol] += 1;
                    rowTotals[curRow] += 1;
                } 
            }           
        }
        
    }
    NSRange rowRange = MakeRange(rowTotals, height);
    NSRange columnRange = MakeRange(columnTotals, width);
    
    CGRect cropBounds = CGRectMake(columnRange.location,rowRange.location, columnRange.length, rowRange.length);
    
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(imageRefWithTransparency, cropBounds);
    
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef];
    if (croppedImageRef == NULL) {
        return nil;
    }
    CFRelease(croppedImageRef);
    
    
    CGFloat ratio = croppedImage.size.width/croppedImage.size.height;
    CGSize newSize;
    if (ratio < tempImage.size.width / tempImage.size.height) {
        newSize = CGSizeMake(MIN(roundf(75.0 * ratio), width), 75);        
    } else {
        newSize = CGSizeMake(tempImage.size.width, MIN(roundf(tempImage.size.width / ratio), tempImage.size.height));
    }
    
    return [croppedImage resizedImageToFitInSize:self.size scaleIfSmaller:NO];
}

- (UIImage *)imageWithWhiteCropped {
    return [self imageWithCropping:NO];
}

- (UIImage *)imageWithTransparentCropped {
    return [self imageWithCropping:YES];
}

- (UIImage *)imageMaskedWithWhiteLevel:(CGFloat)whiteLevel {
    // Make everything lighter than a certain level transparent
    const CGFloat myMaskingColors[6] = {whiteLevel, 255, whiteLevel, 255, whiteLevel, 255};
    CGImageRef maskedImageRef = CGImageCreateWithMaskingColors(self.CGImage, myMaskingColors);
    // The masked CGImage doesn't carry transparency data (Apple Bug?), convert to png and back to recover this
    UIImage *tempImage = [UIImage imageWithCGImage:maskedImageRef];
    
    CFRelease(maskedImageRef);
    // make all non-transparent areas black
    UIGraphicsBeginImageContextWithOptions(tempImage.size, NO, 0.0);
    
    CGRect rect = CGRectZero;
    rect.size = tempImage.size;
    
    [[UIColor blackColor] set];
    UIRectFill(rect);
    
    [tempImage drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
    UIImage *finishedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finishedImage;
}

-(UIImage *)imageCroppedToSize:(CGSize)previewSize {
    
    // By default, core graphics has trouble keeping track of image orientation (UIKit works fine). The following reorients the backing CGImage
    UIImage *reorientedImage =  [self resizedImageToFitInSize:self.size scaleIfSmaller:NO];
    
    // Crop the image to the preview window bounds
    CGSize rawSize = self.size;
    CGFloat ratio = rawSize.width/previewSize.width;
    CGFloat cropHeight = roundf(ratio * previewSize.height);
    CGRect cropRect = CGRectMake(0, roundf((rawSize.height - cropHeight)/2.0), rawSize.width, cropHeight);
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(reorientedImage.CGImage, cropRect);
    UIImage *returnImage = [UIImage imageWithCGImage:croppedImageRef];
    CFRelease(croppedImageRef);
    
    return returnImage;
}

@end
