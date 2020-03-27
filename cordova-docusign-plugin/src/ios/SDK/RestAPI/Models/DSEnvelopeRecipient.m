//
//  DSEnvelopeRecipient.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/6/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSEnvelopeRecipient.h"

#import "DSEnvelopeRecipientEmailNotification.h"

#import "NSValueTransformer+DS_CustomTransformers.h"

@implementation DSEnvelopeRecipient

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ NSStringFromSelector(@selector(clientUserID)) : @"clientUserId",
              NSStringFromSelector(@selector(recipientID)) : @"recipientId",
              NSStringFromSelector(@selector(recipientIDGuid)) : @"recipientIdGuid",
              NSStringFromSelector(@selector(userID)) : @"userId" };
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:NSStringFromSelector(@selector(declinedDateTime))] ||
        [key isEqualToString:NSStringFromSelector(@selector(deliveredDateTime))] ||
        [key isEqualToString:NSStringFromSelector(@selector(sentDateTime))] ||
        [key isEqualToString:NSStringFromSelector(@selector(signedDateTime))]) {
        return [NSValueTransformer valueTransformerForName:DSDateValueTransformerName];
    }
    return nil;
}

+ (NSValueTransformer *)emailNotificationJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[DSEnvelopeRecipientEmailNotification class]];
}

@end
