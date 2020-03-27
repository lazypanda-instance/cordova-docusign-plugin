//
//  DSSigningAPIDeclineSigning.h
//  DocuSignIt
//
//  Created by Stephen Parish on 12/12/13.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

//#import <Mantle/Mantle.h>
#import "Mantle.h"

@interface DSSigningAPIDeclineSigning : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *reason;
@property (nonatomic) BOOL consentWithdrawn;

- (instancetype)initWithReason:(NSString *)reason consentWithdrawn:(BOOL)consentWithdrawn;

@end
