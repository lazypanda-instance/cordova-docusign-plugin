//
//  DSEnvelopesListResponse.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/8/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSEnvelopesListResponse.h"

#import "DSEnvelopesListEnvelope.h"

@implementation DSEnvelopesListResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ NSStringFromSelector(@selector(nextURL)) : @"nextUri",
              NSStringFromSelector(@selector(previousURL)) : @"previousUri",
              NSStringFromSelector(@selector(totalSetSize)) : @"totalRows",
              NSStringFromSelector(@selector(envelopes)) : @"folderItems" };
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:NSStringFromSelector(@selector(nextURL))] ||
        [key isEqualToString:NSStringFromSelector(@selector(previousURL))]) {
        return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
    }
    if ([key isEqualToString:NSStringFromSelector(@selector(envelopes))]) {
        return [MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:[DSEnvelopesListEnvelope class]];
    }
    return nil;
}

@end
