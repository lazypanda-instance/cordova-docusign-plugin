//
//  NSURL+DS_QueryDictionary.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/2/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "NSURL+DS_QueryDictionary.h"

#import "NSString+DS_URLEncoding.h"

@implementation NSURL (DS_QueryDictionary)

- (id)initWithString:(NSString *)URLString queryDictionary:(NSDictionary *)queryDictionary {
    NSString *queryString = [self ds_queryStringFromDictionary:queryDictionary];
    if (queryString) {
        URLString = [URLString stringByAppendingFormat:@"?%@", queryString];
    }
    return [self initWithString:URLString];
}

- (id)initWithString:(NSString *)URLString relativeToURL:(NSURL *)baseURL queryDictionary:(NSDictionary *)queryDictionary {
    NSString *queryString = [self ds_queryStringFromDictionary:queryDictionary];
    if (queryString) {
        URLString = [URLString stringByAppendingFormat:@"?%@", queryString];
    }
    return [self initWithString:URLString relativeToURL:baseURL];
}

- (NSString *)ds_queryStringFromDictionary:(NSDictionary *)queryDictionary {
    if ([queryDictionary count] == 0) {
        return nil;
    }
    
    NSMutableArray *keyValuePairs = [[NSMutableArray alloc] initWithCapacity:[queryDictionary count]];
    [queryDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        id encodedValue = value;
        if ([value isKindOfClass:[NSString class]]) {
            encodedValue = [value ds_URLEncodedString];
        }
        [keyValuePairs addObject:[[NSString alloc] initWithFormat:@"%@=%@", [key ds_URLEncodedString], encodedValue]];
    }];
    return [keyValuePairs componentsJoinedByString:@"&"];
}

- (NSDictionary *)ds_queryDictionary {
    if ([[self query] length] == 0) {
        return nil;
    }
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSArray *parameterStrings = [[self query] componentsSeparatedByString:@"&"];
    for (NSString *parameterString in parameterStrings) {
        NSArray *keyAndValue = [parameterString componentsSeparatedByString:@"="];
        if ([keyAndValue count] != 2) {
            return nil;
        }
        NSString *key = [[keyAndValue firstObject] ds_URLDecodedString];
        NSString *value = [[keyAndValue lastObject] ds_URLDecodedString];
        result[key] = value;
    }
    return result;
}

@end
