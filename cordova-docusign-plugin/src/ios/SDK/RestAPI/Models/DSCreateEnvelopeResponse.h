//
//  DSCreateEnvelopeResponse.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/15/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSRestAPIResponseModel.h"

#import "DSEnvelopeStatus.h"

@interface DSCreateEnvelopeResponse : DSRestAPIResponseModel

@property (nonatomic) NSString         *envelopeID;
@property (nonatomic) DSEnvelopeStatus  status;
@property (nonatomic) NSDate           *statusDateTime;

@end
