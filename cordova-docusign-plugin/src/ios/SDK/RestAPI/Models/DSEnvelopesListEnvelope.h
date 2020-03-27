//
//  DSEnvelopesListEnvelope.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/9/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

//#import <Mantle/Mantle.h>
#import "Mantle.h"

@class DSEnvelopeRecipientsResponse;

@interface DSEnvelopesListEnvelope : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *emailSubject;
@property (nonatomic) NSString *envelopeID;
@property (nonatomic) NSString *folderID;
@property (nonatomic) NSString *status;

@property (nonatomic) NSString *ownerName;
@property (nonatomic) NSString *senderUserID;
@property (nonatomic) NSString *senderName;
@property (nonatomic) NSString *senderEmail;
@property (nonatomic) NSString *senderCompany;

@property (nonatomic) NSDate   *createdDateTime;
@property (nonatomic) NSDate   *sentDateTime;
@property (nonatomic) NSDate   *completedDateTime;
@property (nonatomic) NSDate   *expireDateTime;

@property (nonatomic) DSEnvelopeRecipientsResponse *recipients;

@end
