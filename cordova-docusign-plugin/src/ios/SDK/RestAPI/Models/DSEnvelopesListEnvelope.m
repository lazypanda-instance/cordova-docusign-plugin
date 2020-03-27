//
//  DSEnvelopesListEnvelope.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/9/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSEnvelopesListEnvelope.h"

#import "DSEnvelopeRecipientsResponse.h"

#import "NSValueTransformer+DS_CustomTransformers.h"

@implementation DSEnvelopesListEnvelope

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ NSStringFromSelector(@selector(envelopeID)) : @"envelopeId",
              NSStringFromSelector(@selector(folderID)) : @"folderId",
              NSStringFromSelector(@selector(senderUserID)) : @"senderUserId",
              NSStringFromSelector(@selector(emailSubject)) : @"subject" };
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:NSStringFromSelector(@selector(completedDateTime))] ||
        [key isEqualToString:NSStringFromSelector(@selector(createdDateTime))] ||
        [key isEqualToString:NSStringFromSelector(@selector(expireDateTime))] ||
        [key isEqualToString:NSStringFromSelector(@selector(sentDateTime))]) {
        return [NSValueTransformer valueTransformerForName:DSDateValueTransformerName];
    } else if ([key isEqualToString:NSStringFromSelector(@selector(recipients))]) {
        return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[DSEnvelopeRecipientsResponse class]];
    }
    return nil;
}

@end
