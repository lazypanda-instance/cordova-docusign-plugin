//
//  DSCondition+DSCommon.m
//  DSTextEntryValidation
//
//  Created by Arlo Armstrong on 5/14/14.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSCondition+DSCommon.h"


@implementation DSCondition (DSCommon)


+ (DSCondition *)notBlankCondition {
    return [[DSCondition alloc] initWithLocalizedDescription:NSLocalizedString(@"Must contain at least one character", nil) evaluationBlock:^BOOL(DSCondition *condition, NSString *text) {
        return [[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0;
    }];
}


+ (DSCondition *)conditionWithMinLength:(NSUInteger)length {
    DSCondition *result = [[DSCondition alloc] initWithLocalizedDescription:[NSString stringWithFormat:NSLocalizedString(@"Must contain at least %d characters", @"placeholder is a number"), length] evaluationBlock:^BOOL(DSCondition *condition, NSString *text) {
        return [text length] >= length;
    }];
    result.evaluationHint = DSConditionEvaluationHintNone;
    return result;
}


+ (DSCondition *)conditionWithMaxLength:(NSUInteger)length {
    DSCondition *result = [[DSCondition alloc] initWithLocalizedDescription:[NSString stringWithFormat:NSLocalizedString(@"Must be less than %d characters", @"placeholder is a number"), length] evaluationBlock:^BOOL(DSCondition *condition, NSString *text) {
        return [text length] <= length;
    }];
    result.evaluationHint = result.evaluationHint | DSConditionEvaluationHintDisableViolation;
    return result;
}


+ (DSCondition *)noSpacesCondition {
    return [[DSCondition alloc] initWithLocalizedDescription:NSLocalizedString(@"Must not contain space(s)", nil) evaluationBlock:^BOOL(DSCondition *condition, NSString *text) {
        return [text rangeOfString:@" "].location == NSNotFound;
    }];
}


+ (DSCondition *)validURLCondition {
    return [[DSCondition alloc] initWithLocalizedDescription:NSLocalizedString(@"Must be a valid URL", nil) evaluationBlock:^BOOL(DSCondition *condition, NSString *text) {
        // NSURL URLWithString returns nil if the URL is malformed
        // valid URLs: test1, http://localhost, http://test1.docusign.net/
        return [NSURL URLWithString:text] != nil;
    }];
}


+ (DSCondition *)alphanumericCondition {
    return [[DSCondition alloc] initWithLocalizedDescription:NSLocalizedString(@"Must only contain letters and numbers", nil) evaluationBlock:^BOOL(DSCondition *condition, NSString *text) {
        NSCharacterSet *unwantedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        return [text rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound;
    }];
}


@end
