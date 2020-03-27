//
//  NSURL+DS_QueryDictionary.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/2/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (DS_QueryDictionary)

- (id)initWithString:(NSString *)URLString queryDictionary:(NSDictionary *)queryDictionary;
- (id)initWithString:(NSString *)URLString relativeToURL:(NSURL *)baseURL queryDictionary:(NSDictionary *)queryDictionary;

- (NSString *)ds_queryStringFromDictionary:(NSDictionary *)queryDictionary;
- (NSDictionary *)ds_queryDictionary;

@end
