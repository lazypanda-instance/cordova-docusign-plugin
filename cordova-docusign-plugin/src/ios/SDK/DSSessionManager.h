//
//  DSSessionManager.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 4/22/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DSRestAPIEnvironment.h"

#import "DSSigningViewControllerDelegate.h"

#import "DSSignaturePart.h"

#import "DSLogicalEnvelopeGroup.h"

//@import UIKit;
#import <UIKit/UIKit.h>

extern NSString * const DSSessionManagerErrorDomain;

extern NSString * const DSSessionManagerErrorUserInfoKeyStatusCode;
extern NSString * const DSSessionManagerErrorUserInfoKeyErrorCodeString;
extern NSString * const DSSessionManagerErrorUserInfoKeyErrorMessage;

typedef NS_ENUM(NSInteger, DSSessionManagerErrorCode) {
    DSSessionManagerErrorCodeHTTPStatus = -1,
    DSSessionManagerErrorCodeUnknown = 0,
    DSSessionManagerErrorCodeUserAuthenticationFailed = 1
};

extern NSString * const DSSessionManagerNotificationTaskStarted;
extern NSString * const DSSessionManagerNotificationTaskFinished;

extern NSString * const DSSessionManagerNotificationUserInfoKeyData;
extern NSString * const DSSessionManagerNotificationUserInfoKeyDestinationURL;
extern NSString * const DSSessionManagerNotificationUserInfoKeyError;


@class DSSessionManager, DSSigningViewController, DSNetworkLogger;

@class DSLoginInformationResponse, DSLoginAccount;
@class DSCreateEnvelopeResponse;
@class DSEnvelopesListResponse;
@class DSEnvelopeDetailsResponse, DSEnvelopeRecipientsResponse;
@class DSUserSignaturesResponse, DSUserSignature;


@protocol DSSessionManagerAuthenticationDelegate <NSObject>

@required
/**
 *  Called after the -authenticate method completes successfully.
 *
 *  @param sessionManager the DSSessionManager which has successfully authenticated
 *  @param account        the DSLoginAccount which has been authenticated
 */
- (void)sessionManager:(DSSessionManager *)sessionManager authenticationSucceededWithAccount:(DSLoginAccount *)account;

/**
 *  Called after the -authenticate method fails.
 *
 *  @param sessionManager the DSSessionManager which failed to authenticate
 *  @param error          an NSError describing why the authentication failed
 */
- (void)sessionManager:(DSSessionManager *)sessionManager authenticationFailedWithError:(NSError *)error;

@optional
/**
 *  Called after a successful authentication and passed an array of DSLoginAccount. Call the completeAuthenticationHandler passing in the accountID of the selected account to finish authentication. Until this block is called the sessionManager will not be authenticated. If not implemented the default account will be selected.
 *
 *  @param sessionManager                the DSSessionManager which has successfully authenticated
 *  @param accounts                      an array of DSLoginAccount
 *  @param completeAuthenticationHandler call this block with the selected accountID to complete authentication
 */
- (void)sessionManager:(DSSessionManager *)sessionManager chooseAccountIDFromAvailableAccounts:(NSArray *)accounts completeAuthenticationHandler:(void (^)(NSString *accountID))completeAuthenticationHandler;

@end


@interface DSSessionManager : NSObject


/**
 *  The baseURL of the currently authenticated user or the default baseURL if not yet authenticated. E.g. https://demo.docusign.net/restapi/v2/ or https://www.docusign.net/restapi/v2/
 */
@property (nonatomic, readonly) NSURL *baseURL;


/**
 *  The account information of the authenticated user.
 */
@property (nonatomic, readonly) DSLoginAccount *account;


/**
 *  The OAuth token for the authenticated user
 */
@property (nonatomic, readonly) NSString *authToken;



/**
 *  Preferred initializer. Returns a DSSessionManager ready to authenticate the user with the given token.
 *
 *  @param integratorKey Identifies the application accessing the DocuSign API. See https://www.docusign.com/developer-center/quick-start/first-api-call
 *  @param environment   The DocuSign environment for which the integrator key is valid e.g. demo or production
 *  @param authToken     An oauth2 token with which to authenticate the DocuSign user. See https://www.docusign.com/p/RESTAPIGuide/RESTAPIGuide.htm#OAuth2/OAuth2%20Authentication%20Support%20in%20DocuSign%20REST%20API.htm
 *
 *  @return A newly initialized DSSessionManager object.
 */
- (instancetype)initWithIntegratorKey:(NSString *)integratorKey forEnvironment:(DSRestAPIEnvironment)environment authToken:(NSString *)authToken authDelegate:(id<DSSessionManagerAuthenticationDelegate>)authDelegate;


/**
 *  Returns a DSSessionManager ready to authenticate with the given user credentials.
 *
 *  @param integratorKey Identifies the application accessing the DocuSign API. See https://www.docusign.com/developer-center/quick-start/first-api-call
 *  @param environment   The DocuSign environment for which the integrator key is valid e.g. demo or production
 *  @param username      The email or userID (GUID) of the DocuSign user.
 *  @param password      The plaintext password or apiPassword of the DocuSign user.
 *
 *  @return A newly initialized DSSessionManager object.
 */
- (instancetype)initWithIntegratorKey:(NSString *)integratorKey forEnvironment:(DSRestAPIEnvironment)environment username:(NSString *)username password:(NSString *)password authDelegate:(id<DSSessionManagerAuthenticationDelegate>)authDelegate;


#pragma mark - Authentication

/**
 *  The object to be notified when authentication succeds, fails, or finds multiple user accounts.
 */
@property (nonatomic, weak) id<DSSessionManagerAuthenticationDelegate> authenticationDelegate;

/**
 *  Returns YES if the user has been successfully authenticated, NO otherwise.
 */
@property (nonatomic, readonly, getter = isAuthenticated) BOOL authenticated;


/**
 *  Must be invoked before making additional requests via the SDK.
 */
- (void)authenticate;


#pragma mark - Network Tasks

/**
 *  All pending in progress API requests will be cancelled and the associated callbacks will not be not be fired. The sessionManager can still be used for subsequent requests. Note: to cancel individual requests maintain a reference to the specific NSURLSessionTask object.
 */
- (void)cancelAllTasks;


- (NSURLSessionDataTask *)startLoginInformationTaskWithCompletionHandler:(void (^)(DSLoginInformationResponse *response, NSError *error))completionHandler;


- (NSURLSessionDataTask *)startSigningURLTaskForRecipientWithID:(NSString *)recipientID
                                                         userID:(NSString *)userID
                                                   clientUserID:(NSString *)clientUserID
                                               inEnvelopeWithID:(NSString *)envelopeID
                                                      returnURL:(NSURL *)returnURL
                                              completionHandler:(void (^)(NSString *signingURLString, NSError *error))completionHandler;


- (NSURLSessionDataTask *)startCreateSelfSignEnvelopeTaskWithFileName:(NSString *)fileName
                                                              fileURL:(NSURL *)fileURL
                                                    completionHandler:(void (^)(DSCreateEnvelopeResponse *response, NSError *error))completionHandler;


- (NSURLSessionDataTask *)startEnvelopesListTaskWithLogicalGrouping:(DSLogicalEnvelopeGroup)logicalGroup
                                                              range:(NSRange)range
                                                           fromDate:(NSDate *)fromDate
                                                             toDate:(NSDate *)toDate
                                                  includeRecipients:(BOOL)includeRecipients
                                                  completionHandler:(void (^)(DSEnvelopesListResponse *response, NSError *error))completionHandler;


- (NSURLSessionDataTask *)startEnvelopeDetailsTaskForEnvelopeWithID:(NSString *)envelopeID
                                                  completionHandler:(void (^)(DSEnvelopeDetailsResponse *response, NSError *error))completionHandler;


- (NSURLSessionDataTask *)startEnvelopeRecipientsTaskForEnvelopeWithID:(NSString *)envelopeID
                                                     completionHandler:(void (^)(DSEnvelopeRecipientsResponse *response, NSError *error))completionHandler;


- (NSURLSessionDownloadTask *)startDownloadCompletedDocumentTaskForEnvelopeWithID:(NSString *)envelopeID
                                                               destinationFileURL:(NSURL *)destinationFileURL
                                                                completionHandler:(void (^)(NSError *error))completionHandler;


- (NSURLSessionDataTask *)startRecipientSignatureCreateTaskForRecipientID:(NSString *)recipientID
                                                         inEnvelopeWithID:(NSString *)envelopeID
                                                                    image:(UIImage *)image
                                                            signaturePart:(DSSignaturePart)signaturePart
                                                        completionHandler:(void (^)(NSError *error))completionHandler;


- (NSURLSessionDataTask *)startRecipientSignatureDetailsTaskForRecipientID:(NSString *)recipientID
                                                          inEnvelopeWithID:(NSString *)envelopeID
                                                         completionHandler:(void (^)(DSUserSignature *response, NSError *error))completionHandler;


- (NSURLSessionDataTask *)startSignaturesTaskWithCompletionHandler:(void (^)(DSUserSignaturesResponse *response, NSError *error))completionHandler;


- (NSURLSessionDataTask *)startSignatureDeleteTaskForSignatureWithID:(NSString *)signatureID
                                                   completionHandler:(void (^)(NSError *error))completionHandler;


#pragma mark - Signing


- (DSSigningViewController *)signingViewControllerForRecipientWithID:(NSString *)recipientID inEnvelopeWithID:(NSString *)envelopeID delegate:(id<DSSigningViewControllerDelegate>)delegate;


#pragma mark - Logging


@property (nonatomic, readonly) DSNetworkLogger *logger;


@end
