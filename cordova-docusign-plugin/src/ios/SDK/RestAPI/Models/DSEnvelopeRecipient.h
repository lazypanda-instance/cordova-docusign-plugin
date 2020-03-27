//
//  DSEnvelopeRecipient.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/6/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

//#import <Mantle/Mantle.h>
#import "Mantle.h"

@class DSEnvelopeRecipientEmailNotification;

@interface DSEnvelopeRecipient : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString  *clientUserID;
@property (nonatomic) NSArray   *customFields; // NSString
@property (nonatomic) NSString  *declinedReason;
@property (nonatomic) NSString  *deliveryMethod;
@property (nonatomic) NSString  *email;
@property (nonatomic) DSEnvelopeRecipientEmailNotification *emailNotification;
@property (nonatomic) NSString  *name;
@property (nonatomic) NSString  *note;
@property (nonatomic) NSString  *recipientID;
@property (nonatomic) NSString  *recipientIDGuid;
@property (nonatomic) NSString  *roleName;
@property (nonatomic) NSInteger  routingOrder;
@property (nonatomic) NSString  *status;
@property (nonatomic) NSString  *statusCode;
@property (nonatomic) NSString  *userID;

@property (nonatomic) NSDate    *declinedDateTime;
@property (nonatomic) NSDate    *deliveredDateTime;
@property (nonatomic) NSDate    *sentDateTime;
@property (nonatomic) NSDate    *signedDateTime;

@end
