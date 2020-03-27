//
//  DSSigningAPIRecipient.h
//  DocuSignIt
//
//  Created by Stephen Parish on 3/24/14.
//  Copyright (c) 2014 DocuSign, Inc. All rights reserved.
//

//#import <Mantle/Mantle.h>
#import "Mantle.h"

@interface DSSigningAPIRecipient : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *email;

@end
