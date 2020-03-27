//
//  NSString+DS_URLEncoding.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/2/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "NSString+DS_URLEncoding.h"

@implementation NSString (DS_URLEncoding)

- (NSString *)ds_URLEncodedString {
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                     (__bridge CFStringRef)(self),
                                                                     NULL,
                                                                     (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                     kCFStringEncodingUTF8));
}

- (NSString *)ds_URLDecodedString {
	return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                     (__bridge CFStringRef)self,
                                                                                     (CFStringRef)@"",
                                                                                     kCFStringEncodingUTF8));
}

@end
