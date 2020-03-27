//
//  DSEnvelopeDetailsResponse.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/5/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSEnvelopeDetailsResponse.h"

#import "NSValueTransformer+DS_CustomTransformers.h"

@implementation DSEnvelopeDetailsResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ NSStringFromSelector(@selector(envelopeID)) : @"envelopeId",
              NSStringFromSelector(@selector(emailBody)) : @"emailBlurb" };
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:NSStringFromSelector(@selector(completedDateTime))] ||
               [key isEqualToString:NSStringFromSelector(@selector(createdDateTime))] ||
               [key isEqualToString:NSStringFromSelector(@selector(declinedDateTime))] ||
               [key isEqualToString:NSStringFromSelector(@selector(deletedDateTime))] ||
               [key isEqualToString:NSStringFromSelector(@selector(deliveredDateTime))] ||
               [key isEqualToString:NSStringFromSelector(@selector(sentDateTime))] ||
               [key isEqualToString:NSStringFromSelector(@selector(statusChangedDateTime))] ||
               [key isEqualToString:NSStringFromSelector(@selector(voidedDateTime))]) {
        return [NSValueTransformer valueTransformerForName:DSDateValueTransformerName];
    }
    return nil;
}

@end
