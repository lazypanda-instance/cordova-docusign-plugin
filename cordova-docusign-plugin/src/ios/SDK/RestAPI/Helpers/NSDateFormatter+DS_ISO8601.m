//
//  NSDateFormatter+DS_ISO8601.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/5/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "NSDateFormatter+DS_ISO8601.h"

@implementation NSDateFormatter (DS_ISO8601)

+ (NSDateFormatter *)ds_ISO8601DateFormatter {
    NSDateFormatter *result = [[NSDateFormatter alloc] init];
    [result setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [result setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
    return result;
}

@end
