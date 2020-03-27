//
//  DSValidatedTextField.h
//  DSTextEntryValidation
//
//  Created by Arlo Armstrong on 5/14/14.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class DSValidator;


/**
 *  A UITextField which has an associated collection of conditions which can be evaluated against the contained text.
 */
@interface DSValidatedTextField : UITextField


/**
 *  A collection of conditions which can be used to evaluate the validity of the text.
 */
@property (nonatomic, strong) DSValidator *validator;


/**
 *  Returns an array of DSConditions with which the textField text does not comply.
 *
 *  @return an NSArray of DSConditions with which the textField text does not comply. If the array is nil or empty then all conditions have been met
 */
- (NSArray *)conditionsViolated;


/**
 *  Returns YES if all conditions are met by the textField text, NO otherwise.
 *
 *  @return YES if all conditions are met by the textField text, NO otherwise
 */
- (BOOL)isValid;


/**
 *  Returns an NSString suitable for display to the user detailing the reason a condition was violated or nil if all conditions have been met.
 *
 *  @param text an NSString to evaluate against all conditions
 *
 *  @return an NSString suitable for display to the user detailing the reason a condition was violated or nil if all conditions have been met
 */
- (NSString *)descriptionOfFirstConditionViolated;


@end