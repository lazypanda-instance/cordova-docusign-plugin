//
//  DSValidatedTextField.m
//  DSTextEntryValidation
//
//  Created by Arlo Armstrong on 5/14/14.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSValidatedTextField.h"
#import "DSValidator.h"


@implementation DSValidatedTextField


- (NSArray *)conditionsViolated {
    return [self.validator conditionsViolatedByText:self.text];
}


- (BOOL)isValid {
    return [[self conditionsViolated] count] == 0;
}


- (NSString *)descriptionOfFirstConditionViolated {
    return [self.validator descriptionOfFirstConditionViolatedByText:self.text];
}


@end
