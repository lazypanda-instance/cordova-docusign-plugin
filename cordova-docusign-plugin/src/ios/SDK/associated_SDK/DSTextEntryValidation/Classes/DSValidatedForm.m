//
//  DSValidatedForm.m
//  DSTextEntryValidation
//
//  Created by Arlo Armstrong on 5/14/14.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSValidatedForm.h"
#import "DSValidatedTextField.h"
#import "DSValidator.h"
#import "CMPopTipView.h"


@interface DSValidatedForm () <UITextFieldDelegate, CMPopTipViewDelegate>


@property (nonatomic, strong) DSValidatedTextField *currentlyViolatedTextField;
@property (nonatomic, strong) CMPopTipView *popTipView;
@property (nonatomic, strong) UIView *targetViewForPopTip;
@property (nonatomic, strong) UIView *superViewForPopTip;


@end


@implementation DSValidatedForm


+ (CMPopTipView *)defaultPopTipWithMessage:(NSString *)message {
    CMPopTipView *result = [[CMPopTipView alloc] initWithMessage:message];
    [result setBackgroundColor:[UIColor whiteColor]];
    [result setBorderColor:[UIColor redColor]];
    [result setTextColor:[UIColor redColor]];
    result.animation = CMPopTipAnimationPop;
    return result;
}


#pragma mark - Lifecycle


- (instancetype)initWithTextFields:(NSArray *)textFields delegate:(id<DSValidatedFormDelegate>) delegate {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.textFields = textFields; // using accessor on purpose because we want to be made the delegate of the textFields
    _delegate = delegate;
    
    return self;
}


#pragma mark - Accessors


- (void)setTextFields:(NSArray *)textFields {
    for (DSValidatedTextField *textField in textFields) {
        textField.delegate = self;
    }
    _textFields = textFields;
}


#pragma mark - Public


- (void)addTextFields:(NSArray *)textFields {
    NSArray *nonNilArray = self.textFields ?: @[];
    self.textFields = [nonNilArray arrayByAddingObjectsFromArray:textFields];
}


- (void)removeTextFields:(NSArray *)textFields {
    NSMutableArray *nonNilArray = [NSMutableArray arrayWithArray:self.textFields ?: @[]];
    [nonNilArray removeObjectsInArray:textFields];
    self.textFields = [NSArray arrayWithArray:nonNilArray];
}


- (NSArray *)violatedTextFields {
    return [self.textFields filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(DSValidatedTextField *textField, NSDictionary *bindings) {
        return [[textField conditionsViolated] count] > 0;
    }]];
}


- (BOOL)isValid {
    return [[self violatedTextFields] count] == 0;
}


- (void)displayFirstViolation {
    NSArray *violatedFields = [self violatedTextFields];
    if (![self isDisplayingViolation] && [violatedFields count] > 0) {
        [self showViolationForTextField:violatedFields[0]];
    }
}


- (BOOL)isDisplayingViolation {
    return self.popTipView != nil;
}


- (void)dismissViolation {
    [self dismissViolationAnimated:YES];
}


#pragma mark - Conceptual Presentation, Delegate Notification, Internal State Remembering


- (void)showViolationForTextField:(DSValidatedTextField *)textField {
    [self showViolationForTextField:textField withText:textField.text];
}


- (void)showViolationForTextField:(DSValidatedTextField *)textField withText:(NSString *)text {
    if ([self isDisplayingViolation] && self.currentlyViolatedTextField != textField) {
        [self hideViolationForTextField:self.currentlyViolatedTextField];
    }
    self.currentlyViolatedTextField = textField;
    BOOL shouldShowViolation = YES;
    if ([self.delegate respondsToSelector:@selector(validatedForm:shouldShowViolationForTextField:)]) {
        shouldShowViolation = [self.delegate validatedForm:self shouldShowViolationForTextField:textField];
    }
    if (shouldShowViolation) {
        self.targetViewForPopTip = textField;
        if ([self.delegate respondsToSelector:@selector(validatedForm:targetViewForViolatedTextField:)]) {
            self.targetViewForPopTip = [self.delegate validatedForm:self targetViewForViolatedTextField:textField];
        }
        self.superViewForPopTip = [textField superview];
        if ([self.delegate respondsToSelector:@selector(validatedForm:superViewForViolatedTextField:)]) {
            self.superViewForPopTip = [self.delegate validatedForm:self superViewForViolatedTextField:textField];
        }
        [self presentViolation:[textField.validator descriptionOfFirstConditionViolatedByText:text] fromView:self.targetViewForPopTip inView:self.superViewForPopTip animated:YES];
        if ([self.delegate respondsToSelector:@selector(validatedForm:didShowViolationForTextField:)]) {
            [self.delegate validatedForm:self didShowViolationForTextField:textField];
        }
    }
}


- (void)hideViolationForTextField:(DSValidatedTextField *)textField {
    if (![self isDisplayingViolation]) {
        return;
    }
    BOOL shouldHideViolation = YES;
    if ([self.delegate respondsToSelector:@selector(validatedForm:shouldHideViolationForTextField:)]) {
        shouldHideViolation = [self.delegate validatedForm:self shouldHideViolationForTextField:textField];
    }
    if (shouldHideViolation) {
        [self dismissViolationAnimated:YES];
    }
    if ([self.delegate respondsToSelector:@selector(validatedForm:didHideViolationForTextField:)]) {
        [self.delegate validatedForm:self didHideViolationForTextField:textField];
    }
}


#pragma mark - Concrete Presentation


- (void)presentViolation:(NSString *)violation fromView:(UIView *)fromView inView:(UIView *)inView animated:(BOOL)animated {
    if ([self isDisplayingViolation] && self.targetViewForPopTip == fromView && self.superViewForPopTip == inView) {
        if (![self.popTipView.message isEqual:violation]) {
            self.popTipView.message = violation;
            [self.popTipView presentPointingAtView:fromView inView:inView animated:NO];
        }
    } else {
        self.popTipView = [[self class] defaultPopTipWithMessage:violation];
        self.popTipView.delegate = self;
        [self.popTipView presentPointingAtView:fromView inView:inView animated:animated];
    }
}


- (void)dismissViolationAnimated:(BOOL)animated {
    if ([self isDisplayingViolation]) {
        [self.popTipView dismissAnimated:animated];
        self.popTipView = nil;
        self.currentlyViolatedTextField = nil;
    }
}


#pragma mark - CMPopTipViewDelegate


- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    self.popTipView = nil;
    self.currentlyViolatedTextField = nil;
    if ([self.delegate respondsToSelector:@selector(validatedForm:didHideViolationForTextField:)]) {
        [self.delegate validatedForm:self didHideViolationForTextField:self.currentlyViolatedTextField];
    }
}


#pragma mark - UITextFieldDelegate


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    DSValidatedTextField *validatedTextField = (DSValidatedTextField *)textField;
    if ([textField.text length] > 0 && ![validatedTextField.validator isValidText:validatedTextField.text evaluationHints:DSConditionEvaluationHintImmediate]) {
        [self showViolationForTextField:validatedTextField];
    }
    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.delegate textFieldDidBeginEditing:textField];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    DSValidatedTextField *validatedTextField = (DSValidatedTextField *)textField;
    if ([self isDisplayingViolation] && ![validatedTextField.validator isValidText:updatedText evaluationHints:DSConditionEvaluationHintImmediate]) {
        [self showViolationForTextField:validatedTextField withText:updatedText];
    } else if (validatedTextField == self.currentlyViolatedTextField) {
        if ([validatedTextField.validator isValidText:updatedText]) {
            [self hideViolationForTextField:validatedTextField];
        } else {
            [self showViolationForTextField:validatedTextField withText:updatedText];
        }
    }
    BOOL result = [[validatedTextField.validator conditionsViolatedByText:updatedText evaluationHints:DSConditionEvaluationHintDisableViolation] count] == 0;
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        result = [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return result;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.delegate textFieldDidEndEditing:textField];
    }
}


- (BOOL)textFieldShouldClear:(UITextField *)textField {
    DSValidatedTextField *validatedTextField = (DSValidatedTextField *)textField;
    if (self.currentlyViolatedTextField == validatedTextField) {
        [self hideViolationForTextField:validatedTextField];
    }
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        result = [self.delegate textFieldShouldClear:textField];
    }
    return result;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DSValidatedTextField *validatedTextField = (DSValidatedTextField *)textField;
    if (![self isDisplayingViolation] && ![validatedTextField isValid]) {
        [self showViolationForTextField:validatedTextField];
    }
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        result = [self.delegate textFieldShouldReturn:textField];
    }
    return result;
}


@end
