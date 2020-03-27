//
//  DSSigningAPIAddCCRecipients.m
//  DocuSignIt
//
//  Created by Stephen Parish on 3/24/14.
//  Copyright (c) 2014 DocuSign, Inc. All rights reserved.
//

#import "DSSigningAPIAddCCRecipients.h"

#import "DSSigningAPIRecipient.h"

@implementation DSSigningAPIAddCCRecipients

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return nil;
}

+ (NSValueTransformer *)recipientsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[DSSigningAPIRecipient class]];
}

@end
