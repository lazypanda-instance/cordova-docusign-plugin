//
//  DSStoryboardFactory.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/2/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSStoryboardFactory.h"

@interface DSStoryboardFactory ()

@property (nonatomic) NSCache *cache;

@end

@implementation DSStoryboardFactory

#pragma mark - Lifecycle

+ (instancetype)sharedStoryboardFactory {
    static id DSStoryboardFactorySharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DSStoryboardFactorySharedInstance = [[self alloc] init];
    });
    
    return DSStoryboardFactorySharedInstance;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.cache = [[NSCache alloc] init];
    return self;
}

#pragma mark - Public

- (UIStoryboard *)loginStoryboard {
    return [self storyboardWithName:@"DSLogin"];
}

- (UIStoryboard *)signingStoryboard {
    return [self storyboardWithName:@"DSSigning"];
}

- (UIStoryboard *)signatureStoryboard {
    return [self storyboardWithName:@"DSSignature"];
}

#pragma mark - Private

- (UIStoryboard *)storyboardWithName:(NSString *)storyboardName {
    UIStoryboard *result = [self.cache objectForKey:storyboardName];
    if (!result) {
        result = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        if (!result) {
            return nil;
        }
        [self.cache setObject:result forKey:storyboardName];
    }
    return result;
}

@end
