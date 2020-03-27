//
//  DSRestAPIResponseModel.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/6/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

//#import <Mantle/Mantle.h>
#import "Mantle.h"

@interface DSRestAPIResponseModel : MTLModel <MTLJSONSerializing>

@property (nonatomic) id rawJSONObject;

@end
