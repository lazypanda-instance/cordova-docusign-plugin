//
//  DSFieldTextCondition.h
//  DSTextEntryValidation
//
//  Created by Arlo Armstrong on 5/14/14.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSCondition.h"


@interface DSFieldTextCondition : DSCondition


@property (nonatomic, strong) UITextField *referenceField;


- (instancetype)initWithLocalizedDescription:(NSString *)localizedDescription referenceField:(UITextField *)referenceField;


@end
