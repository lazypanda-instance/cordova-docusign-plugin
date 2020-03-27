//
//  NSValueTransformer+DS_CustomTransformers.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/5/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "NSValueTransformer+DS_CustomTransformers.h"

//#import <Mantle/Mantle.h>
#import "Mantle.h"

#import "NSDateFormatter+DS_ISO8601.h"

#import "DSEnvelopeStatus.h"


NSString * const DSBOOLValueTransformerName = @"DSBOOLValueTransformerName";
NSString * const DSDateValueTransformerName = @"DSDateValueTransformerName";
NSString * const DSEnvelopeStatusValueTransformerName = @"DSEnvelopeStatusValueTransformerName";


@implementation NSValueTransformer (DS_CustomTransformers)

+ (void)load {
	@autoreleasepool {
        
		[NSValueTransformer setValueTransformer:[MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id BOOLObject) {
            if ([BOOLObject isKindOfClass:[NSNumber class]]) {
                return BOOLObject;
            } else if ([BOOLObject isKindOfClass:[NSString class]]) {
                return @([BOOLObject caseInsensitiveCompare:@"true"] == NSOrderedSame);
            }
            return @NO;
        } reverseBlock:^id(id BOOLNumber) {
            if (![BOOLNumber isKindOfClass:[NSNumber class]]) {
                return @"false";
            }
            return [BOOLNumber boolValue] ? @"true" : @"false";
        }]
                                        forName:DSBOOLValueTransformerName];
        
        
        NSDateFormatter *dateFormatter = [NSDateFormatter ds_ISO8601DateFormatter];
        [NSValueTransformer setValueTransformer:[MTLValueTransformer reversibleTransformerWithForwardBlock:^id(id stringObject) {
            if (![stringObject isKindOfClass:[NSString class]]) {
                return nil;
            }
            
            return [dateFormatter dateFromString:stringObject];
        } reverseBlock:^id(id dateObject) {
            if (![dateObject isKindOfClass:[NSDate class]]) {
                return nil;
            }
            
            return [dateFormatter stringFromDate:dateObject];
        }]
                                        forName:DSDateValueTransformerName];
        
        
        NSMutableDictionary *statusMappingDictionary = [[NSMutableDictionary alloc] init];
        for (NSNumber *envelopeStatusNumber in DSEnvelopeStatusesArray()) {
            DSEnvelopeStatus status = [envelopeStatusNumber integerValue];
            statusMappingDictionary[DSStringFromEnvelopeStatus(status)] = envelopeStatusNumber;
        }
        NSValueTransformer *statusValueTransformer = [NSValueTransformer mtl_valueMappingTransformerWithDictionary:statusMappingDictionary];
        [NSValueTransformer setValueTransformer:statusValueTransformer forName:DSEnvelopeStatusValueTransformerName];

	}
}

@end
