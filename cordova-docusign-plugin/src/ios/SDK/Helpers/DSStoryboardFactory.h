//
//  DSStoryboardFactory.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/2/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DSStoryboardFactory : NSObject

+ (instancetype)sharedStoryboardFactory;

- (UIStoryboard *)loginStoryboard;

- (UIStoryboard *)signingStoryboard;

- (UIStoryboard *)signatureStoryboard;

@end
