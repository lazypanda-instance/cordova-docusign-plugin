//
//  DSSigningAPIDeclineSigning.m
//  DocuSignIt
//
//  Created by Stephen Parish on 12/12/13.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSSigningAPIDeclineSigning.h"

#import "NSValueTransformer+DS_CustomTransformers.h"

@implementation DSSigningAPIDeclineSigning

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return nil;
}

+ (NSValueTransformer *)consentWithdrawnNumberJSONTransformer {
    return [NSValueTransformer valueTransformerForName:DSBOOLValueTransformerName];
}

- (instancetype)initWithReason:(NSString *)reason consentWithdrawn:(BOOL)consentWithdrawn {
    self = [super init];
    if (!self) {
        return nil;
    }
    _reason = reason;
    _consentWithdrawn = consentWithdrawn;
    return self;
}

@end
