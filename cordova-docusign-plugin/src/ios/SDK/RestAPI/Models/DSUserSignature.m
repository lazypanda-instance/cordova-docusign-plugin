//
//  DSUserSignature.m
//  DocuSign iOS SDK
//
//  Created by Deyton Sehn on 5/8/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSUserSignature.h"

@implementation DSUserSignature

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ NSStringFromSelector(@selector(signatureID)) : @"signatureId",
              NSStringFromSelector(@selector(signature150ImageID)) : @"signature150ImageId",
              NSStringFromSelector(@selector(initials150ImageID)) : @"initials150ImageId" };
}

@end
