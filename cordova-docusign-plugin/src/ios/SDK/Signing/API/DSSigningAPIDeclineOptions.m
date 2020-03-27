//
//  DSSigningAPIDeclineOptions.m
//  DocuSignIt
//
//  Created by Stephen Parish on 12/12/13.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSSigningAPIDeclineOptions.h"

#import "NSValueTransformer+DS_CustomTransformers.h"

@implementation DSSigningAPIDeclineOptions

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return nil;
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:NSStringFromSelector(@selector(canUseOwnReason))] ||
        [key isEqualToString:NSStringFromSelector(@selector(reasonIsRequired))] ||
        [key isEqualToString:NSStringFromSelector(@selector(canWithdrawConsent))]) {
        return [NSValueTransformer valueTransformerForName:DSBOOLValueTransformerName];
    }
    return nil;
}

@end
