//
//  DSLoginAccount.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/5/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

//#import <Mantle/Mantle.h>
#import "Mantle.h"

@interface DSLoginAccount : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *accountID;
@property (nonatomic) NSURL    *baseURL;
@property (nonatomic) NSString *email;
@property (nonatomic) BOOL      isDefault;
@property (nonatomic) NSString *accountName;
@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *userName;

@end
