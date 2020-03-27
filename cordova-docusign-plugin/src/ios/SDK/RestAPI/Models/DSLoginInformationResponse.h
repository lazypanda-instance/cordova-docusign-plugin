//
//  DSLoginInformationResponse.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/5/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSRestAPIResponseModel.h"

@interface DSLoginInformationResponse : DSRestAPIResponseModel

@property (nonatomic) NSString *apiPassword;
@property (nonatomic) NSArray  *accounts; // DSLoginAccount

@end
