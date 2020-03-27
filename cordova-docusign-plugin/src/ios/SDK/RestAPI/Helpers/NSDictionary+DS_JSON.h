//
//  NSDictionary+DS_JSON.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 4/25/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DS_JSON)

- (NSData *)ds_JSONData;
- (NSString *)ds_JSONString;

@end
