//
//  DSLoginInformationResponse.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/5/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSLoginInformationResponse.h"

#import "DSLoginAccount.h"

@implementation DSLoginInformationResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"accounts" : @"loginAccounts" };
}

+ (NSValueTransformer *)accountsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[DSLoginAccount class]];
}

@end
