//
//  DSValidatedForm.h
//  DSTextEntryValidation
//
//  Created by Arlo Armstrong on 5/14/14.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class DSValidatedForm, DSValidatedTextField, CMPopTipView;


@protocol DSValidatedFormDelegate <UITextFieldDelegate>


@optional


/**
 *  Called before a violation message will be displayed due to an unmet condition on textField. Return YES if the prompt should be shown, NO if the display will be handled elsewhere. Default is YES
 *
 *  @param validatedForm the DSValidatedForm containing textField
 *  @param textField     the DSValidatedTextField which has failed to meet at least one condition
 *
 *  @return YES if the prompt should be shown, NO if the display will be handled elsewhere
 */
- (BOOL)validatedForm:(DSValidatedForm *)validatedForm shouldShowViolationForTextField:(DSValidatedTextField *)textField;


/**
 *  Called before a violation message on textField will be hidden. Return YES if the prompt should be hidden, NO if the display will be handled elsewhere. Default is YES.
 *
 *  @param validatedForm the DSValidatedForm containing textField
 *  @param textField     the DSValidatedTextField from which the violation originated
 *
 *  @return YES if the prompt should be hidden, NO if the display will be handled elsewhere
 */
- (BOOL)validatedForm:(DSValidatedForm *)validatedForm shouldHideViolationForTextField:(DSValidatedTextField *)textField;


/**
 *  Called each time before a violation message will be displayed. Return a UIView at which the violation message should be directed. Defaults to the textField.
 *
 *  @param validatedForm the DSValidatedForm containing textField
 *  @param textField     the DSValidatedTextField from which the violation originated
 *
 *  @return a UIView at which the violation message should be directed
 */
- (UIView *)validatedForm:(DSValidatedForm *)validatedForm targetViewForViolatedTextField:(DSValidatedTextField *)textField;


/**
 *  Called each time before a violation message will be displayed. Return a UIView within which the violation message should be displayed. Defaults to the textField's superView.
 *
 *  @param validatedForm the DSValidatedForm containing textField
 *  @param textField     the DSValidatedTextField from which the violation originated
 *
 *  @return a UIView within which the violation message should be displayed
 */
- (UIView *)validatedForm:(DSValidatedForm *)validatedForm superViewForViolatedTextField:(DSValidatedTextField *)textField;


/**
 *  Called after a violation message was displayed.
 *
 *  @param validatedForm the DSValidatedForm containing textField
 *  @param textField     the DSValidatedTextField caused a violation message to be displayed
 */
- (void)validatedForm:(DSValidatedForm *)validatedForm didShowViolationForTextField:(DSValidatedTextField *)textField;


/**
 *  Called after a violation message was hidden.
 *
 *  @param validatedForm the DSValidatedForm containing textField
 *  @param textField     the DSValidatedTextField which, up til recently, had a violation
 */
- (void)validatedForm:(DSValidatedForm *)validatedForm didHideViolationForTextField:(DSValidatedTextField *)textField;


@end


/**
 *  Manages a collection of DSValidatedTextFields, evaluates and displays any conditions not met by the text entered therein. Provides a DSValidatedFormDelegate allowing for a high degree of control/customisation of the validation process.
 */
@interface DSValidatedForm : NSObject


/**
 *  Returns a CMPopTipView configured for display with default values.
 *
 *  @return a CMPopTipView configured for display with default values
 */
+ (CMPopTipView *)defaultPopTipWithMessage:(NSString *)message;


/**
 *  An object complying to DSValidatedFormDelegate that is in charge of the validation process and will be notified and queried as necessary.
 */
@property (nonatomic, weak) id<DSValidatedFormDelegate> delegate;


/**
 *  An NSArray of DSValidatedTextFields which will have their text input validated.
 */
@property (nonatomic, strong) NSArray *textFields;


/**
 *  Convenience initializer for setting the textFields and delegate.
 *
 *  @param textFields an NSArray of DSValidatedTextFields which will have their text input validated
 *  @param delegate   an object complying to DSValidatedFormDelegate that is in charge of the validation process and will be notified and queried as necessary
 *
 *  @return a DSValidatedForm initialized with textFields and delegate
 */
- (instancetype)initWithTextFields:(NSArray *)textFields delegate:(id<DSValidatedFormDelegate>) delegate;


/**
 *  An NSArray of DSValidatedTextFields which will be appended to the existing textFields.
 *
 *  @param textFields an NSArray of DSValidatedTextFields which will be appended to the existing textFields
 */
- (void)addTextFields:(NSArray *)textFields;


/**
 *  An NSArray of DSValidatedTextFields which will be removed from the existing textFields.
 *
 *  @param textFields an NSArray of DSValidatedTextFields which will be removed from the existing textFields.
 */
- (void)removeTextFields:(NSArray *)textFields;


/**
 *  Returns an NSArray of DSValidatedTextFields which have conditions that are not met by their contained text.
 *
 *  @return an NSArray of DSValidatedTextFields which have conditions that are not met by their contained text
 */
- (NSArray *)violatedTextFields;


/**
 *  Returns YES if all textFields have all of their conditions met by their contained text, NO otherwise.
 *
 *  @return YES if all textFields have all of their conditions met by their contained text, NO otherwise
 */
- (BOOL)isValid;


/**
 *  Displays the text of the first unmet condition on the first textField with at least one unmet condition. If a violation is already displayed this method does nothing.
 */
- (void)displayFirstViolation;


/**
 *  Returns YES if a violation is currently displayed, NO otherwise.
 *
 *  @return YES if a violation is currently displayed, NO otherwise
 */
- (BOOL)isDisplayingViolation;


/**
 *  Dismiss a violation animatedly if one is displayed. If no violation is displayed this method does nothing.
 */
- (void)dismissViolation;


@end
