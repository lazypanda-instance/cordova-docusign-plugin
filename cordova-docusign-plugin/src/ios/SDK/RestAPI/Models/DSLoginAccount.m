//
//  DSLoginAccount.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/5/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSLoginAccount.h"

#import "NSValueTransformer+DS_CustomTransformers.h"

@implementation DSLoginAccount

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"accountID" : @"accountId",
              @"baseURL" : @"baseUrl",
              @"accountName" : @"name",
              @"userID" : @"userId" };
}

+ (NSValueTransformer *)isDefaultJSONTransformer {
    return [NSValueTransformer valueTransformerForName:DSBOOLValueTransformerName];
}

+ (NSValueTransformer *)baseURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
