//
//  DSSigningAPICanFinishChanged.m
//  DocuSignIt
//
//  Created by Stephen Parish on 12/12/13.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSSigningAPICanFinishChanged.h"

#import "NSValueTransformer+DS_CustomTransformers.h"

@implementation DSSigningAPICanFinishChanged

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return nil;
}

+ (NSValueTransformer *)canFinishNumberJSONTransformer {
    return [NSValueTransformer valueTransformerForName:DSBOOLValueTransformerName];
}

@end
