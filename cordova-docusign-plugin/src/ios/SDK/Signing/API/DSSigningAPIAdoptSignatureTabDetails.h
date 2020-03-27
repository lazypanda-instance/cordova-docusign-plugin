//
//  DSSigningAPIAdoptSignatureTab.h
//  DocuSignIt
//
//  Created by Stephen Parish on 12/12/13.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

//#import <Mantle/Mantle.h>
#import "Mantle.h"

#import "DSSigningAPITab.h"

@interface DSSigningAPIAdoptSignatureTabDetails : MTLModel <MTLJSONSerializing>

@property (nonatomic) DSSigningAPITab type;
@property (nonatomic) NSInteger left;
@property (nonatomic) NSInteger top;
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;

@end
