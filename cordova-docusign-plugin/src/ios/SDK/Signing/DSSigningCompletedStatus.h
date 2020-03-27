//
//  DSSigningCompletedStatus.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/2/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#ifndef DocuSign_iOS_SDK_DSSigningCompletedStatus_h
#define DocuSign_iOS_SDK_DSSigningCompletedStatus_h

typedef NS_ENUM(NSInteger, DSSigningCompletedStatus) {
    DSSigningCompletedStatusSigned,
    DSSigningCompletedStatusDeferred,
    DSSigningCompletedStatusDeclined
};

#endif
