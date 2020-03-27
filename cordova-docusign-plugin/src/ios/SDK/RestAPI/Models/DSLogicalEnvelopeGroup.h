//
//  DSLogicalEnvelopeGroup.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/9/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#ifndef DocuSign_iOS_SDK_DSLogicalEnvelopeGroup_h
#define DocuSign_iOS_SDK_DSLogicalEnvelopeGroup_h

typedef NS_ENUM(NSInteger, DSLogicalEnvelopeGroup) {
    DSLogicalEnvelopeGroupDrafts,
    DSLogicalEnvelopeGroupAwaitingASignature,
    DSLogicalEnvelopeGroupAwaitingMySignature,
    DSLogicalEnvelopeGroupCompleted
};

static inline NSString * DSStringFromLogicalEnvelopeGroup(DSLogicalEnvelopeGroup logicalGroup) {
    switch (logicalGroup) {
        case DSLogicalEnvelopeGroupDrafts:
            return @"drafts";
            break;
        case DSLogicalEnvelopeGroupAwaitingASignature:
            return @"out_for_signature";
            break;
        case DSLogicalEnvelopeGroupAwaitingMySignature:
            return @"awaiting_my_signature";
            break;
        case DSLogicalEnvelopeGroupCompleted:
            return @"completed";
            break;
    }
    return nil;
}

#endif
