//
//  DSSigningAPIConsumerDisclosure.h
//  DocuSignIt
//
//  Created by Stephen Parish on 12/12/13.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

//#import <Mantle/Mantle.h>
#import "Mantle.h"

@interface DSSigningAPIConsumerDisclosure : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *senderName;
@property (nonatomic) NSString *senderCompany;
@property (nonatomic) NSString *esignAgreement;

@end
