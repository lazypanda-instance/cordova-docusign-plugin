//
//  DSValidator.m
//  DSTextEntryValidation
//
//  Created by Arlo Armstrong on 5/14/14.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSValidator.h"


@implementation DSValidator


- (instancetype)initWithConditions:(NSArray *)conditions {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _conditions = conditions;

    return self;
}


- (NSArray *)conditionsViolatedByText:(NSString *)text {
    return [self conditionsViolatedByText:text evaluationHints:DSConditionEvaluationHintNone];
}


- (NSArray *)conditionsViolatedByText:(NSString *)text evaluationHints:(DSConditionEvaluationHint)evaluationHints {
    return [self.conditions filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(DSCondition *condition, NSDictionary *bindings) {
        return ![condition isValidText:text] && (evaluationHints == DSConditionEvaluationHintNone || condition.evaluationHint & evaluationHints);
    }]];
}


- (BOOL)isValidText:(NSString *)text {
    return [self isValidText:text evaluationHints:DSConditionEvaluationHintNone];
}


- (BOOL)isValidText:(NSString *)text evaluationHints:(DSConditionEvaluationHint)evaluationHints {
    return [[self conditionsViolatedByText:text evaluationHints:evaluationHints] count] == 0;
}


- (NSString *)descriptionOfFirstConditionViolatedByText:(NSString *)text {
    return [self descriptionOfFirstConditionViolatedByText:text evaluationHints:DSConditionEvaluationHintNone];
}


- (NSString *)descriptionOfFirstConditionViolatedByText:(NSString *)text evaluationHints:(DSConditionEvaluationHint)evaluationHints {
    NSString *result;
    NSArray *violatedConditions = [self conditionsViolatedByText:text evaluationHints:evaluationHints];
    if ([violatedConditions count] > 0) {
        result = ((DSCondition *)violatedConditions[0]).localizedDescription;
    }
    return result;
}


@end
