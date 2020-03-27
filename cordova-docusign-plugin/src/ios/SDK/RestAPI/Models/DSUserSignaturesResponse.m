//
//  DSUserSignaturesResponse.m
//  DocuSign iOS SDK
//
//  Created by Deyton Sehn on 5/8/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSUserSignaturesResponse.h"
#import "DSUserSignature.h"

@implementation DSUserSignaturesResponse

+ (NSValueTransformer *)userSignaturesJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[DSUserSignature class]];
}

@end
