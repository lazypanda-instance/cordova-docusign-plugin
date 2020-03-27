//
//  DSEnvelopeStatus.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/8/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#ifndef DocuSign_iOS_SDK_DSEnvelopeStatus_h
#define DocuSign_iOS_SDK_DSEnvelopeStatus_h

typedef NS_ENUM(NSInteger, DSEnvelopeStatus) {
    DSEnvelopeStatusDraft,
    DSEnvelopeStatusSent,
    DSEnvelopeStatusDelivered,
    DSEnvelopeStatusSigned,
    DSEnvelopeStatusDeclined,
    DSEnvelopeStatusCompleted,
    DSEnvelopeStatusVoided,
    DSEnvelopeStatusDeleted,
    DSEnvelopeStatusTimedOut,
    DSEnvelopeStatusProcessing
};

static inline NSString * DSStringFromEnvelopeStatus(DSEnvelopeStatus status) {
    switch (status) {
        case DSEnvelopeStatusDraft:
            return @"created";
            break;
        case DSEnvelopeStatusSent:
            return @"sent";
            break;
        case DSEnvelopeStatusDelivered:
            return @"delivered";
            break;
        case DSEnvelopeStatusSigned:
            return @"signed";
            break;
        case DSEnvelopeStatusDeclined:
            return @"declined";
            break;
        case DSEnvelopeStatusCompleted:
            return @"completed";
            break;
        case DSEnvelopeStatusVoided:
            return @"voided";
            break;
        case DSEnvelopeStatusDeleted:
            return @"deleted";
            break;
        case DSEnvelopeStatusTimedOut:
            return @"timedOut";
            break;
        case DSEnvelopeStatusProcessing:
            return @"processing";
            break;
    }
    return nil;
}

static inline NSArray * DSEnvelopeStatusesArray() {
    return @[ @(DSEnvelopeStatusSent),
              @(DSEnvelopeStatusSigned),
              @(DSEnvelopeStatusVoided),
              @(DSEnvelopeStatusDraft),
              @(DSEnvelopeStatusDeleted),
              @(DSEnvelopeStatusDeclined),
              @(DSEnvelopeStatusTimedOut),
              @(DSEnvelopeStatusCompleted),
              @(DSEnvelopeStatusDelivered),
              @(DSEnvelopeStatusProcessing) ];
}

#endif
