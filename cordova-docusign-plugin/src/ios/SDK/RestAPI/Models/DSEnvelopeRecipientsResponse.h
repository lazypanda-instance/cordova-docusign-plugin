//
//  DSEnvelopeRecipientsResponse.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/6/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSRestAPIResponseModel.h"

@interface DSEnvelopeRecipientsResponse : DSRestAPIResponseModel

@property (nonatomic) NSArray   *signers; // DSEnvelopeSigner
@property (nonatomic) NSArray   *inPersonSigners; // DSEnvelopeInPersonSigner
@property (nonatomic) NSInteger  recipientCount;
@property (nonatomic) NSInteger  currentRoutingOrder;

- (NSArray *)allSigners; // DSEnvelopeRecipients

@end
