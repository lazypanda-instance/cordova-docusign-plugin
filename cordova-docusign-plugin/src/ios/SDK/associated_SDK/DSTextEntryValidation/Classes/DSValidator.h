//
//  DSValidator.h
//  DSTextEntryValidation
//
//  Created by Arlo Armstrong on 5/14/14.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSCondition.h"


/**
 *  A collection of conditions which can evaluate the validity of some text. Arbitrarily complex validations can be performed by combining conditions using logical operators e.g. an OR condition.
 */
@interface DSValidator : NSObject


/**
 *  A collection of DSConditions used to evaluate the validity of some text.
 */
@property (nonatomic, strong) NSArray *conditions;


/**
 *  Convenience initializer for setting the conditions.
 *
 *  @param conditions a collection of DSConditions used to evaluate the validity of some text
 *
 *  @return a DSValidator initialized with a collection of conditions
 */
- (instancetype)initWithConditions:(NSArray *)conditions;


/**
 *  Returns an array of DSConditions with which the given text does not comply.
 *
 *  @param text an NSString to evaluate against all conditions
 *
 *  @return an NSArray of DSConditions with which the given text does not comply. If the array is nil or empty then all conditions have been met
 */
- (NSArray *)conditionsViolatedByText:(NSString *)text;


/**
 *  Returns an array of DSConditions with which the given text does not comply. Conditions are only evaluated if they have the specified evaluationHints.
 *
 *  @param text             an NSString to evaluate against all conditions
 *  @param evaluationHints  a mask specifying which conditions should be evaluated. The hints may be combined using the C bitwise OR operator. DSConditionEvaluationHintNone will evaluate all conditions
 *
 *  @return an NSArray of DSConditions with which the given text does not comply. If the array is nil or empty then all conditions have been met
 */
- (NSArray *)conditionsViolatedByText:(NSString *)text evaluationHints:(DSConditionEvaluationHint)evaluationHints;


/**
 *  Returns YES if all conditions have been met, NO otherwise.
 *
 *  @param text an NSString to evaluate against all conditions
 *
 *  @return YES if all conditions have been met, NO otherwise
 */
- (BOOL)isValidText:(NSString *)text;


/**
 *  Returns YES if all conditions have been met, NO otherwise. Conditions are only evaluated if they have the specified evaluationHints.
 *
 *  @param text             an NSString to evaluate against all conditions
 *  @param evaluationHints  a mask specifying which conditions should be evaluated. The hints may be combined using the C bitwise OR operator. DSConditionEvaluationHintNone will evaluate all conditions
 *
 *  @return YES if all conditions have been met, NO otherwise
 */
- (BOOL)isValidText:(NSString *)text evaluationHints:(DSConditionEvaluationHint)evaluationHints;


/**
 *  Returns an NSString suitable for display to the user detailing the reason a condition was violated or nil if all conditions have been met.
 *
 *  @param text an NSString to evaluate against all conditions
 *
 *  @return an NSString suitable for display to the user detailing the reason a condition was violated or nil if all conditions have been met
 */
- (NSString *)descriptionOfFirstConditionViolatedByText:(NSString *)text;


/**
 *  Returns an NSString suitable for display to the user detailing the reason a condition was violated or nil if all conditions have been met. Conditions are only evaluated if they have the specified evaluationHints.
 *
 *  @param text             an NSString to evaluate against all conditions
 *  @param evaluationHints  a mask specifying which conditions should be evaluated. The hints may be combined using the C bitwise OR operator. DSConditionEvaluationHintNone will evaluate all conditions
 *
 *  @return an NSString suitable for display to the user detailing the reason a condition was violated or nil if all conditions have been met
 */
- (NSString *)descriptionOfFirstConditionViolatedByText:(NSString *)text evaluationHints:(DSConditionEvaluationHint)evaluationHints;


@end