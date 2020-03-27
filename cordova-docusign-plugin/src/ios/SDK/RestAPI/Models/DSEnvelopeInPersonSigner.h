//
//  DSEnvelopeInPersonSigner.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/6/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSEnvelopeRecipient.h"

@interface DSEnvelopeInPersonSigner : DSEnvelopeRecipient

@property (nonatomic) NSString *hostName;
@property (nonatomic) NSString *hostEmail;
@property (nonatomic) NSString *signerName;

@end
