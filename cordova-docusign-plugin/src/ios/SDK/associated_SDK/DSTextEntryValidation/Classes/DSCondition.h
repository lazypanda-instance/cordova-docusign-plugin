//
//  DSCondition.h
//  DSTextEntryValidation
//
//  Created by Arlo Armstrong on 5/14/14.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class DSCondition;


typedef NS_OPTIONS(NSInteger, DSConditionEvaluationHint) {
    DSConditionEvaluationHintNone             = 0,
    DSConditionEvaluationHintImmediate        = 1 << 0,
    DSConditionEvaluationHintDisableViolation = 1 << 1
};


typedef BOOL(^DSConditionEvaluationBlock)(DSCondition *condition, NSString *text);


/**
 *  A criterium which can evaluate the validity of some text along with a message to display if the criterium is violated.
 */
@interface DSCondition : NSObject


/**
 *  The message to show a user if the condition has been violated.
 */
@property (nonatomic, strong) NSString *localizedDescription;


/**
 *  A mask specifying hints for when the condition should be evaluated. The hints may be specified by combining them with the C bitwise OR operator. Defaults to DSConditionEvaluationHintNone.
 */
@property (nonatomic, assign) DSConditionEvaluationHint evaluationHint;


/**
 *  An optional block which, if present, is evaluated to determine whether the condition has been met.
 */
@property (nonatomic, copy) DSConditionEvaluationBlock evaluationBlock;


/**
 *  Convenience initializer for setting the localizedDescription and evaluationBlock.
 *
 *  @param localizedDescription the message to show a user if the condition has been violated
 *  @param evaluationBlock      a block which is evaluated to determine whether the condition has been met
 *
 *  @return a DSCondition initialized with a localizedDescription and evaluationBlock
 */
- (instancetype)initWithLocalizedDescription:(NSString *)localizedDescription evaluationBlock:(DSConditionEvaluationBlock)evaluationBlock;


/**
 *  Returns NO if the condition is violated, YES otherwise. By default evaluates the given text against the evaluationBlock else returns YES. Override this method in a subclass to create custom conditions.
 *
 *  @return NO if the condition is violated, YES otherwise
 */
- (BOOL)isValidText:(NSString *)text;


@end