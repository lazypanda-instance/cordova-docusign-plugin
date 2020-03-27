//
//  NSURL+DSMimeType.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/15/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "NSURL+DSMimeType.h"

#import <MobileCoreServices/MobileCoreServices.h>


@implementation NSURL (DSMimeType)


- (NSString *)ds_mimeType {
    if (![self isFileURL]) {
        return nil;
    }
    NSString *extension = [self pathExtension];
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)(extension), NULL);
    NSString *result = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    if (type != NULL) {
        CFRelease(type);
    }
    return result;
}


@end
