//
//  DSEnvelopeRecipientsResponse.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/6/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSEnvelopeRecipientsResponse.h"

#import "DSEnvelopeSigner.h"
#import "DSEnvelopeInPersonSigner.h"

@implementation DSEnvelopeRecipientsResponse

+ (NSValueTransformer *)signersJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[DSEnvelopeSigner class]];
}

+ (NSValueTransformer *)inPersonSignersJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[DSEnvelopeInPersonSigner class]];
}

- (NSArray *)allSigners {
    return [self.signers arrayByAddingObjectsFromArray:self.inPersonSigners];
}

@end
