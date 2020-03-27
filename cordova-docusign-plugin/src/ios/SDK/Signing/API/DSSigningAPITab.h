//
//  DSSigningAPITab.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 4/25/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#ifndef DocuSign_iOS_SDK_DSSigningAPITab_h
#define DocuSign_iOS_SDK_DSSigningAPITab_h

typedef NS_ENUM(NSInteger, DSSigningAPITab) {
    DSSigningAPITabNone,
    DSSigningAPITabSignHere,
    DSSigningAPITabInitialHere,
    DSSigningAPITabFullName,
    DSSigningAPITabDateSigned,
    DSSigningAPITabTextMultiline,
    DSSigningAPITabCheckbox,
    DSSigningAPITabCompany,
    DSSigningAPITabTitle
};

#endif
