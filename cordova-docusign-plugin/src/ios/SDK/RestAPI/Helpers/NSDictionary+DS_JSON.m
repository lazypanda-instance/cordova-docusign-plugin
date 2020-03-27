//
//  NSDictionary+DS_JSON.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 4/25/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "NSDictionary+DS_JSON.h"

@implementation NSDictionary (DS_JSON)

- (NSData *)ds_JSONData {
    return [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
}

- (NSString *)ds_JSONString {
    return [[NSString alloc] initWithData:[self ds_JSONData] encoding:NSUTF8StringEncoding];
}

@end
