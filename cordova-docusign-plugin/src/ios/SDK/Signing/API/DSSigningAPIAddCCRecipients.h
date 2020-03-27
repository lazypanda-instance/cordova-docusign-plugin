//
//  DSSigningAPIAddCCRecipients.h
//  DocuSignIt
//
//  Created by Stephen Parish on 3/24/14.
//  Copyright (c) 2014 DocuSign, Inc. All rights reserved.
//

//#import <Mantle/Mantle.h>
#import "Mantle.h"

@interface DSSigningAPIAddCCRecipients : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *subject;
@property (nonatomic) NSString *message;
@property (nonatomic) NSArray *recipients;

@end
