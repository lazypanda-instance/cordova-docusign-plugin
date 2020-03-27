//
//  DSUserSignature.h
//  DocuSign iOS SDK
//
//  Created by Deyton Sehn on 5/8/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSRestAPIResponseModel.h"

@interface DSUserSignature : DSRestAPIResponseModel

@property (nonatomic) NSString *signatureID;
@property (nonatomic) NSString *signatureInitials;
@property (nonatomic) NSString *signatureName;

@property (nonatomic) NSString *signature150ImageID;
@property (nonatomic) NSString *initials150ImageID;

@end
