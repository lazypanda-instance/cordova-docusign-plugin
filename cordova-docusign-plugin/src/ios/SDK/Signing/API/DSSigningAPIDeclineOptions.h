//
//  DSSigningAPIDeclineOptions.h
//  DocuSignIt
//
//  Created by Stephen Parish on 12/12/13.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

//#import <Mantle/Mantle.h>
#import "Mantle.h"

@interface DSSigningAPIDeclineOptions : MTLModel <MTLJSONSerializing>

@property (nonatomic) BOOL canUseOwnReason;
@property (nonatomic) BOOL reasonIsRequired;
@property (nonatomic) BOOL canWithdrawConsent;
@property (nonatomic) NSArray *reasonChoices;

@end
