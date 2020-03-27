//
//  NSString+DS_ValidEmail.m
//  DocuSign iOS SDK
//
//  Created by Deyton Sehn on 5/29/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "NSString+DS_ValidEmail.h"

@implementation NSString (DS_ValidEmail)

- (BOOL)ds_isValidEmail {
    NSPredicate *validEmailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",
                                      @"((([^<>()\\[\\]\\.,;:\\s@\"]+(\\.[^<>()\\[\\]\\.,;:\\s@\"]+)*)|(\".+\"))@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\])|(([a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,})))"];
    return [validEmailPredicate evaluateWithObject:[self lowercaseString]];
}

@end
