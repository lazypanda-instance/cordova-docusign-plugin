//
//  DSFieldTextCondition.m
//  DSTextEntryValidation
//
//  Created by Arlo Armstrong on 5/14/14.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSFieldTextCondition.h"


@implementation DSFieldTextCondition


- (instancetype)initWithLocalizedDescription:(NSString *)localizedDescription referenceField:(UITextField *)referenceField {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.localizedDescription = localizedDescription;
    _referenceField = referenceField;

    return self;
}


@end
