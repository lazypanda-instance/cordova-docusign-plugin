//
//  DSStartsWithFieldTextCondition.m
//  DSTextEntryValidation
//
//  Created by Arlo Armstrong on 5/14/14.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSStartsWithFieldTextCondition.h"


@implementation DSStartsWithFieldTextCondition


- (BOOL)isValidText:(NSString *)text {
    return [self.referenceField.text hasPrefix:text];
}


@end
