//
//  NSString+DS_URLEncoding.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/2/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DS_URLEncoding)

- (NSString *)ds_URLEncodedString;
- (NSString *)ds_URLDecodedString;

@end
