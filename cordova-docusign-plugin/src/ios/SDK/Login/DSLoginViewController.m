//
//  DSLoginViewController.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/9/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSLoginViewController.h"

#import "DSStoryboardFactory.h"
#import "UIViewController+DSLayoutGuides.h"

#import "DSSessionManager.h"

#import "DSChooseAccountViewController.h"
#import "DSLoginAccount.h"


@interface DSLoginViewController () <UITextFieldDelegate, DSSessionManagerAuthenticationDelegate, DSChooseAccountViewControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopConstraint;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityindicator;

@property (nonatomic) NSString *integratorKey;
@property (nonatomic) DSRestAPIEnvironment environment;
@property (nonatomic) NSString *email;

@property (nonatomic) DSSessionManager *sessionManager;
@property (nonatomic, copy) void (^completeAuthenticationHandler)(NSString *accountID);

@end


@implementation DSLoginViewController


#pragma mark - Lifecycle


- (instancetype)initWithIntegratorKey:(NSString *)integratorKey forEnvironment:(DSRestAPIEnvironment)environment delegate:(id<DSLoginViewControllerDelegate>)delegate {
    return [self initWithIntegratorKey:integratorKey forEnvironment:environment email:nil delegate:delegate];
}


- (instancetype)initWithIntegratorKey:(NSString *)integratorKey forEnvironment:(DSRestAPIEnvironment)environment email:(NSString *)email delegate:(id<DSLoginViewControllerDelegate>)delegate {
    self = [[[DSStoryboardFactory sharedStoryboardFactory] loginStoryboard] instantiateViewControllerWithIdentifier:@"DSLoginViewController"];
    if (!self) {
        return nil;
    }
    
    _integratorKey = integratorKey;
    _environment = environment;
    _email = email;
    _delegate = delegate;
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.emailTextField.text = self.email;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    self.scrollViewTopConstraint.constant = -[self ds_topLayoutGuideHeight];
    
    [self.loginActivityindicator startAnimating];
    
    [self performSelector:@selector(performLogin) withObject:nil afterDelay:1.0];
}


#pragma mark - User Interaction


- (IBAction)cancelTapped:(id)sender {
    [self.delegate loginViewControllerCancelled:self];
}


- (IBAction)loginTapped:(id)sender {
    [self performLogin];
}


#pragma mark - 


- (void)performLogin {
    // TODO: improved input validation
    //NSString *email = self.emailTextField.text;
    //NSString *password = self.passwordTextField.text;
    
    NSString *email = self.userNameMessage;
    NSString *password = self.userPasswordMessage;
    
    if ([email length] == 0 || [password length] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Please enter your credentials" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.sessionManager = [[DSSessionManager alloc] initWithIntegratorKey:self.integratorKey
                                                           forEnvironment:self.environment
                                                                 username:email
                                                                 password:password
                                                             authDelegate:self];
    [self.sessionManager authenticate];
}


#pragma mark - DSSessionManagerAuthenticationDelegate


- (void)sessionManager:(DSSessionManager *)sessionManager authenticationSucceededWithAccount:(DSLoginAccount *)account {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.loginActivityindicator stopAnimating];
    [self.delegate loginViewController:self didLoginWithSessionManager:self.sessionManager];
}


- (void)sessionManager:(DSSessionManager *)sessionManager authenticationFailedWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.loginActivityindicator stopAnimating];
    [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil] show];
}


- (void)sessionManager:(DSSessionManager *)sessionManager chooseAccountIDFromAvailableAccounts:(NSArray *)accounts completeAuthenticationHandler:(void (^)(NSString *accountID))completeAuthenticationHandler {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.loginActivityindicator stopAnimating];
    self.completeAuthenticationHandler = completeAuthenticationHandler;
    DSChooseAccountViewController *viewController = [[DSChooseAccountViewController alloc] initWithAccounts:accounts delegate:self];
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - DSChooseAccountViewControllerDelegate


- (void)chooseAccountViewController:(DSChooseAccountViewController *)controller didChooseAccount:(DSLoginAccount *)account {
    if (self.completeAuthenticationHandler) {
        self.completeAuthenticationHandler(account.accountID);
        self.completeAuthenticationHandler = nil;
    }
}


- (void)chooseAccountViewControllerCancelled:(DSChooseAccountViewController *)controller {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [self performLogin];
        [textField resignFirstResponder];
    }
    return YES;
}


@end
