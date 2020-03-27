//
//  DSCreateEnvelopeResponse.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/15/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSCreateEnvelopeResponse.h"

#import "NSValueTransformer+DS_CustomTransformers.h"


@implementation DSCreateEnvelopeResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ NSStringFromSelector(@selector(envelopeID)) : @"envelopeId" };
}

+ (NSValueTransformer *)statusJSONTransformer {
    return [NSValueTransformer valueTransformerForName:DSEnvelopeStatusValueTransformerName];
}

+ (NSValueTransformer *)statusDateTimeJSONTransformer {
    return [NSValueTransformer valueTransformerForName:DSDateValueTransformerName];
}

@end
