//
//  DSRestAPIEnvironment.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/27/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#ifndef DocuSign_iOS_SDK_DSRestAPIEnvironment_h
#define DocuSign_iOS_SDK_DSRestAPIEnvironment_h

typedef NS_ENUM(NSInteger, DSRestAPIEnvironment) {
    DSRestAPIEnvironmentDemo,
    DSRestAPIEnvironmentProduction
};

static inline NSString *DSURLStringFromEnvironment(DSRestAPIEnvironment environment) {
    switch (environment) {
        case DSRestAPIEnvironmentDemo:
            return @"https://demo.docusign.net";
            break;
        case DSRestAPIEnvironmentProduction:
            return @"https://www.docusign.net";
            break;
    }
}

#endif
