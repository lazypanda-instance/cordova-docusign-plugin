//
//  NSValueTransformer+DS_CustomTransformers.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/5/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: I do not like these names, I think they should be like DSValueTransformerNameBOOL instead
extern NSString * const DSBOOLValueTransformerName;
extern NSString * const DSDateValueTransformerName;
extern NSString * const DSEnvelopeStatusValueTransformerName;

@interface NSValueTransformer (DS_CustomTransformers)

@end
