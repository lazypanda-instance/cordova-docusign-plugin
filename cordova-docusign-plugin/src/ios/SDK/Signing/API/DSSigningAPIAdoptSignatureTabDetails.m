//
//  DSSigningAPIAdoptSignatureTab.m
//  DocuSignIt
//
//  Created by Stephen Parish on 12/12/13.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSSigningAPIAdoptSignatureTabDetails.h"

@implementation DSSigningAPIAdoptSignatureTabDetails

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return nil;
}

+ (NSValueTransformer *)typeJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(id stringObject) {
        if (![stringObject isKindOfClass:[NSString class]]) {
            return nil;
        }
        
        NSDictionary *transforms = @{ @"SignHere" : @(DSSigningAPITabSignHere),
                                      @"SignHereOptional" : @(DSSigningAPITabSignHere),
                                      @"InitialHere" : @(DSSigningAPITabInitialHere),
                                      @"InitialHereOptional" : @(DSSigningAPITabInitialHere) };
        return transforms[stringObject];
    }];
}

@end
