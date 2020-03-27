//
//  DSEnvelopeDetailsResponse.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/5/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSRestAPIResponseModel.h"

@interface DSEnvelopeDetailsResponse : DSRestAPIResponseModel

@property (nonatomic) NSString *emailBody;
@property (nonatomic) NSString *emailSubject;
@property (nonatomic) NSString *envelopeID;
@property (nonatomic) NSString *status;
@property (nonatomic) NSString *voidedReason;

@property (nonatomic) NSDate   *completedDateTime;
@property (nonatomic) NSDate   *createdDateTime;
@property (nonatomic) NSDate   *declinedDateTime;
@property (nonatomic) NSDate   *deletedDateTime;
@property (nonatomic) NSDate   *deliveredDateTime;
@property (nonatomic) NSDate   *sentDateTime;
@property (nonatomic) NSDate   *statusChangedDateTime;
@property (nonatomic) NSDate   *voidedDateTime;

@end
