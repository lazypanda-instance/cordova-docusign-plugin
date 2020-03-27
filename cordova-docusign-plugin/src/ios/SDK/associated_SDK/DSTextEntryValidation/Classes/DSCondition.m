//
//  DSCondition.m
//  DSTextEntryValidation
//
//  Created by Arlo Armstrong on 5/14/14.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSCondition.h"


@implementation DSCondition


- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _evaluationHint = DSConditionEvaluationHintImmediate;
    
    return self;
}


- (instancetype)initWithLocalizedDescription:(NSString *)localizedDescription evaluationBlock:(DSConditionEvaluationBlock)evaluationBlock {
    self = [self init];
    if (!self) {
        return nil;
    }
    
    _localizedDescription = localizedDescription;
    _evaluationBlock = evaluationBlock;
    
    return self;
}


- (BOOL)isValidText:(NSString *)text {
    BOOL result = YES;
    if (self.evaluationBlock) {
        result = self.evaluationBlock(self, text);
    }
    return result;
}


@end
