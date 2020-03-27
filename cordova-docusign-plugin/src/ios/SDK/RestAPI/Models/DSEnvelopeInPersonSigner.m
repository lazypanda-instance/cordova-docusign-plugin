//
//  DSEnvelopeInPersonSigner.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/6/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSEnvelopeInPersonSigner.h"

@implementation DSEnvelopeInPersonSigner

- (NSString *)name {
    return self.hostName;
}

- (void)setName:(NSString *)name {
    self.hostName = name;
}

- (NSString *)email {
    return self.hostEmail;
}

- (void)setEmail:(NSString *)email {
    self.hostEmail = email;
}

@end
