//
//  DSSessionManager.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 4/22/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSSessionManager.h"

#import "DSSigningViewController.h"

#import "DSNetworkLogger.h"
#import "NSObject+AKANetworkNotificationLogger.h"

#import "NSDateFormatter+DS_ISO8601.h"
#import "NSDictionary+DS_JSON.h"
#import "NSURL+DS_QueryDictionary.h"
#import "NSURL+DSMimeType.h"

#import "DSRestAPIResponseModel.h"

#import "DSLoginInformationResponse.h"
#import "DSLoginAccount.h"

#import "DSCreateEnvelopeResponse.h"

#import "DSEnvelopesListResponse.h"
#import "DSEnvelopeDetailsResponse.h"
#import "DSEnvelopeRecipientsResponse.h"

#import "DSUserSignaturesResponse.h"
#import "DSUserSignature.h"


NSString * const DSSessionManagerErrorDomain = @"DSSessionManagerErrorDomain";

NSString * const DSSessionManagerErrorUserInfoKeyStatusCode = @"DSSessionManagerErrorUserInfoKeyStatusCode";
NSString * const DSSessionManagerErrorUserInfoKeyErrorCodeString = @"DSSessionManagerErrorUserInfoKeyErrorCodeString";
NSString * const DSSessionManagerErrorUserInfoKeyErrorMessage = @"DSSessionManagerErrorUserInfoKeyErrorMessage";

NSString * const DSSessionManagerErrorCodeStringUserAuthenticationFailed = @"USER_AUTHENTICATION_FAILED";

NSString * const DSSessionManagerNotificationTaskStarted = @"DSSessionManagerNotificationTaskStarted";
NSString * const DSSessionManagerNotificationTaskFinished = @"DSSessionManagerNotificationTaskFinished";

NSString * const DSSessionManagerNotificationUserInfoKeyData = @"DSSessionManagerNotificationUserInfoKeyData";
NSString * const DSSessionManagerNotificationUserInfoKeyDestinationURL = @"DSSessionManagerNotificationUserInfoKeyDestinationURL";
NSString * const DSSessionManagerNotificationUserInfoKeyError = @"DSSessionManagerNotificationUserInfoKeyError";

NSString * const DSSessionManagerDefaultVersion = @"v2";


@interface DSSessionManager ()

@property (nonatomic) NSString *integratorKey;
@property (nonatomic, readwrite) NSString *authToken;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *password;

@property (nonatomic) NSString *environment;
@property (nonatomic) NSString *version;

@property (nonatomic) NSURL *baseURL;
@property (nonatomic) DSLoginAccount *account;
@property (nonatomic, getter = isAuthenticated) BOOL authenticated;

@property (nonatomic) NSURLSession *URLSession;

@property (nonatomic) NSDateFormatter *dateFormatter;

@property (nonatomic) DSNetworkLogger *logger;

@end


@implementation DSSessionManager


#pragma mark - Lifecycle


- (instancetype)initWithIntegratorKey:(NSString *)integratorKey forEnvironment:(DSRestAPIEnvironment)environment authToken:(NSString *)authToken authDelegate:(id<DSSessionManagerAuthenticationDelegate>)authDelegate {
    self = [super init];
    if (!self) {
        return nil;
    }
    _integratorKey = integratorKey;
    _environment = DSURLStringFromEnvironment(environment);
    _authToken = authToken;
    _authenticationDelegate = authDelegate;
    return self;
}


- (instancetype)initWithIntegratorKey:(NSString *)integratorKey forEnvironment:(DSRestAPIEnvironment)environment username:(NSString *)username password:(NSString *)password authDelegate:(id<DSSessionManagerAuthenticationDelegate>)authDelegate {
    self = [super init];
    if (!self) {
        return nil;
    }
    _integratorKey = integratorKey;
    _environment = DSURLStringFromEnvironment(environment);
    _username = username;
    _password = password;
    _authenticationDelegate = authDelegate;
    return self;
}


#pragma mark -


- (BOOL)hasIntegratorKey {
    return [self.integratorKey length] > 0;
}


- (BOOL)hasAuthToken {
    return [self.authToken length] > 0;
}


- (BOOL)hasUserNameAndPassword {
    return [self.username length] > 0 && [self.password length] > 0;
}


#pragma mark - Accessors


- (NSString *)version {
    if (!_version) {
        _version = DSSessionManagerDefaultVersion;
    }
    return _version;
}


- (NSURL *)baseURL {
    if (!_baseURL) {
        NSString *URLString = [[NSString alloc] initWithFormat:@"%@/restapi/%@/", self.environment, self.version];
        _baseURL = [[NSURL alloc] initWithString:URLString];
    }
    return _baseURL;
}


- (NSDictionary *)authHeaders {
    if (![self hasIntegratorKey]) {
        return nil;
    }
    if ([self hasAuthToken]) {
        return @{ @"Authorization" : [[NSString alloc] initWithFormat:@"bearer %@", self.authToken] }; // TODO: apple docs say dont alter this header directly - https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/nsmutableurlrequest_Class/Reference/Reference.html#//apple_ref/occ/instm/NSMutableURLRequest/addValue:forHTTPHeaderField:
    } else if ([self hasUserNameAndPassword]) {
        return @{ @"X-DocuSign-Authentication" : [@{ @"IntegratorKey" : self.integratorKey,
                                                     @"Username" : self.username,
                                                     @"Password" : self.password } ds_JSONString] };
    } else {
        return nil;
    }
}


- (NSURLSession *)URLSession {
    if (!_URLSession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _URLSession = [NSURLSession sessionWithConfiguration:configuration];
    }
    return _URLSession;
}


- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [NSDateFormatter ds_ISO8601DateFormatter];
    }
    return _dateFormatter;
}


#pragma mark - Error Handling


- (DSSessionManagerErrorCode)errorCodeForString:(NSString *)errorCodeString {
    if ([errorCodeString isEqualToString:DSSessionManagerErrorCodeStringUserAuthenticationFailed]) {
        return DSSessionManagerErrorCodeUserAuthenticationFailed;
    }
    return DSSessionManagerErrorCodeUnknown;
}


- (NSError *)docuErrorForResponse:(NSURLResponse *)response JSONObject:(id)JSONObject {
    if (!response && !JSONObject) {
        return nil;
    }
    
    NSString *errorCodeString = JSONObject[@"errorCode"];
    NSNumber *statusCodeNumber;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        statusCodeNumber = @([((NSHTTPURLResponse *)response) statusCode]);
    }

    if (!errorCodeString && ([statusCodeNumber integerValue] >= 200 && [statusCodeNumber integerValue] < 300) ) {
        return nil;
    }
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    if (statusCodeNumber) {
        userInfo[DSSessionManagerErrorUserInfoKeyStatusCode] = statusCodeNumber;
    }
    
    if (errorCodeString) {
        userInfo[DSSessionManagerErrorUserInfoKeyErrorCodeString] = errorCodeString;
        NSString *errorMessage = JSONObject[@"message"];
        if (errorMessage) {
            userInfo[NSLocalizedDescriptionKey] = errorMessage;
            userInfo[DSSessionManagerErrorUserInfoKeyErrorMessage] = errorMessage;
        }
        return [NSError errorWithDomain:DSSessionManagerErrorDomain
                                   code:[self errorCodeForString:errorCodeString]
                               userInfo:userInfo];
    } else if (statusCodeNumber) {
        userInfo[NSLocalizedDescriptionKey] = [NSHTTPURLResponse localizedStringForStatusCode:[statusCodeNumber integerValue]];
        return [NSError errorWithDomain:DSSessionManagerErrorDomain
                                   code:DSSessionManagerErrorCodeHTTPStatus
                               userInfo:userInfo];
    }
    
    userInfo[NSLocalizedDescriptionKey] = @"An unknown error occurred.";
    return [NSError errorWithDomain:DSSessionManagerErrorDomain
                               code:DSSessionManagerErrorCodeUnknown
                           userInfo:userInfo];
}


#pragma mark - Authentication


- (void)authenticate {
    [self startLoginInformationTaskWithCompletionHandler:^(DSLoginInformationResponse *response, NSError *error) {
        if (error) {
            [self.authenticationDelegate sessionManager:self authenticationFailedWithError:error];
            return;
        }
        if ([response.accounts count] == 0) {
            [self.authenticationDelegate sessionManager:self authenticationFailedWithError:[NSError errorWithDomain:DSSessionManagerErrorDomain code:DSSessionManagerErrorCodeUserAuthenticationFailed userInfo:@{ NSLocalizedDescriptionKey : @"Invalid account information" }]];
            return;
        }
        
        if ([response.accounts count] == 1) {
            [self completeAuthenticationWithAccount:[response.accounts firstObject] password:response.apiPassword];
            return;
        }
        
        DSLoginAccount *defaultAccount = [[response.accounts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(DSLoginAccount *account, NSDictionary *bindings) {
            return account.isDefault;
        }]] firstObject];
        
        if ([self.authenticationDelegate respondsToSelector:@selector(sessionManager:chooseAccountIDFromAvailableAccounts:completeAuthenticationHandler:)]) {
            [self.authenticationDelegate sessionManager:self chooseAccountIDFromAvailableAccounts:response.accounts completeAuthenticationHandler:^(NSString *accountID) {
                DSLoginAccount *loginAccount = defaultAccount;
                if (accountID) {
                    DSLoginAccount *chosenAccount = [[response.accounts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(DSLoginAccount *account, NSDictionary *bindings) {
                        return [accountID isEqualToString:account.accountID];
                    }]] firstObject];
                    if (chosenAccount) {
                        loginAccount = chosenAccount;
                    }
                }
                [self completeAuthenticationWithAccount:loginAccount password:response.apiPassword];
            }];
        } else {
            [self completeAuthenticationWithAccount:defaultAccount password:response.apiPassword];
        }
    }];
}


- (void)completeAuthenticationWithAccount:(DSLoginAccount *)loginAccount password:(NSString *)password {
    self.environment = [[NSString alloc] initWithFormat:@"%@://%@", [loginAccount.baseURL scheme], [loginAccount.baseURL host]];
    self.baseURL = nil; // will be recreated as needed with updated environment
    
    self.authToken = password;
    self.username = nil;
    self.password = nil;
    self.URLSession = nil; // will be recreated as needed with updated auth headers
    
    self.account = loginAccount;
    self.authenticated = YES;
    
    [self.authenticationDelegate sessionManager:self authenticationSucceededWithAccount:loginAccount];
}


#pragma mark -


- (NSURLSessionDataTask *)startDataTaskToGETRelativeURLString:(NSString *)relativeURLString
                                              queryDictionary:(NSDictionary *)queryDictionary
                                                responseClass:(Class)responseClass
                                            completionHandler:(void (^)(id JSONObject, NSError *error))completionHandler {
    
    return [self startDataTaskWithMethod:@"GET"
                       relativeURLString:relativeURLString
                         queryDictionary:queryDictionary
                                bodyData:nil
                              bodyStream:nil
                       additionalHeaders:nil
                           responseClass:responseClass
                       completionHandler:completionHandler];
}


- (NSURLSessionDataTask *)startDataTaskWithMethod:(NSString *)method
                                relativeURLString:(NSString *)relativeURLString
                                         bodyData:(NSData *)bodyData
                                    responseClass:(Class)responseClass
                                completionHandler:(void (^)(id JSONObject, NSError *error))completionHandler {
    
    return [self startDataTaskWithMethod:method
                       relativeURLString:relativeURLString
                         queryDictionary:nil
                                bodyData:bodyData
                              bodyStream:nil
                       additionalHeaders:nil
                           responseClass:responseClass
                       completionHandler:completionHandler];
}


- (NSURLSessionDataTask *)startDataTaskWithMethod:(NSString *)method
                                relativeURLString:(NSString *)relativeURLString
                                  queryDictionary:(NSDictionary *)queryDictionary
                                         bodyData:(NSData *)bodyData
                                       bodyStream:(NSInputStream *)bodyStream
                                additionalHeaders:(NSDictionary *)additionalHeaders
                                    responseClass:(Class)responseClass
                                completionHandler:(void (^)(id JSONObject, NSError *error))completionHandler {
    
    return (NSURLSessionDataTask *)[self startTaskWithMethod:method
                                           relativeURLString:relativeURLString
                                             queryDictionary:queryDictionary
                                                    bodyData:bodyData
                                                  bodyStream:bodyStream
                                           additionalHeaders:additionalHeaders
                                               responseClass:responseClass
                                             responseFileURL:nil
                                           completionHandler:completionHandler];
}


- (NSURLSessionDownloadTask *)startDownloadTaskWithMethod:(NSString *)method
                                        relativeURLString:(NSString *)relativeURLString
                                          queryDictionary:(NSDictionary *)queryDictionary
                                          responseFileURL:(NSURL *)responseFileURL
                                        completionHandler:(void (^)(NSError *error))completionHandler {
    
    return (NSURLSessionDownloadTask *)[self startTaskWithMethod:method
                                               relativeURLString:relativeURLString
                                                 queryDictionary:queryDictionary
                                                        bodyData:nil
                                                      bodyStream:nil
                                               additionalHeaders:nil
                                                   responseClass:nil
                                                 responseFileURL:responseFileURL
                                               completionHandler:^(id JSONObject, NSError *error) {
                                                   completionHandler(error);
                                               }];
}


- (NSURLSessionTask *)startTaskWithMethod:(NSString *)method
                        relativeURLString:(NSString *)relativeURLString
                          queryDictionary:(NSDictionary *)queryDictionary
                                 bodyData:(NSData *)bodyData
                               bodyStream:(NSInputStream *)bodyStream
                        additionalHeaders:(NSDictionary *)additionalHeaders
                            responseClass:(Class)responseClass
                          responseFileURL:(NSURL *)responseFileURL
                        completionHandler:(void (^)(id JSONObject, NSError *error))completionHandler {
    
    NSURL *resourceURL = [[NSURL alloc] initWithString:relativeURLString relativeToURL:[self baseURL] queryDictionary:queryDictionary];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:resourceURL];
    request.HTTPMethod = method;
    
    [[self authHeaders] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [request addValue:value forHTTPHeaderField:key];
    }];
    
    [additionalHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [request addValue:value forHTTPHeaderField:key];
    }];
    
    if (bodyData) {
        request.HTTPBody = bodyData;
        if ([[request valueForHTTPHeaderField:@"Content-Type"] length] == 0) {
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
    } else {
        request.HTTPBodyStream = bodyStream;
    }
    
    __block NSURLSessionTask *task;
    
    void(^taskCompletion)(id object, NSURLResponse *response, NSError *error) = ^(id dataOrURL, NSURLResponse *response, NSError *error) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        if (responseFileURL) {
            userInfo[DSSessionManagerNotificationUserInfoKeyDestinationURL] = responseFileURL;
        }

        if (error) {
            [self finishTask:task withResponseObject:nil error:error userInfo:userInfo completionHandler:completionHandler];
            return;
        }
        
        if (!dataOrURL) {
            NSError *responseStatusCodeError = [self docuErrorForResponse:response JSONObject:nil];
            [self finishTask:task withResponseObject:nil error:responseStatusCodeError userInfo:userInfo completionHandler:completionHandler];
            return;
        }
        
        if ([dataOrURL isKindOfClass:[NSURL class]]) {
            NSError *fileError;
            if (![[NSFileManager defaultManager] copyItemAtURL:dataOrURL toURL:responseFileURL error:&fileError]) {
                userInfo[DSSessionManagerNotificationUserInfoKeyError] = fileError;
            }
            [self finishTask:task withResponseObject:nil error:fileError userInfo:userInfo completionHandler:completionHandler];
            return;
        }
        
        // dataOrURL is not nil, and not a URL
        
        if ([dataOrURL length] > 0) {
            userInfo[DSSessionManagerNotificationUserInfoKeyData] = dataOrURL;
        }
        
        id JSONObject = [NSJSONSerialization JSONObjectWithData:dataOrURL options:0 error:nil];
        
        NSError *docuError = [self docuErrorForResponse:response JSONObject:JSONObject];
        if (docuError) {
            [self finishTask:task withResponseObject:nil error:docuError userInfo:userInfo completionHandler:completionHandler];
            return;
        }
        
        if (!JSONObject || !responseClass || ![responseClass isSubclassOfClass:[DSRestAPIResponseModel class]]) {
            [self finishTask:task withResponseObject:JSONObject error:nil userInfo:userInfo completionHandler:completionHandler];
            return;
        }
        
        NSError *mappingError;
        DSRestAPIResponseModel *responseObject = [MTLJSONAdapter modelOfClass:responseClass fromJSONDictionary:JSONObject error:&mappingError];
        responseObject.rawJSONObject = JSONObject;
        
        [self finishTask:task withResponseObject:responseObject error:mappingError userInfo:userInfo completionHandler:completionHandler];
    };
    
    if (responseFileURL) {
        task = [self.URLSession downloadTaskWithRequest:request completionHandler:taskCompletion];
    } else {
        task = [self.URLSession dataTaskWithRequest:request completionHandler:taskCompletion];
    }
    
    if (self.logger.logOptions != AKANetworkLoggerOptionsOff) {
        DSNetworkLogger *logger = [self.logger copy];
        task.aka_networkLogger = logger;
        [logger startLoggingObject:task];
    }
    [task resume];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DSSessionManagerNotificationTaskStarted object:task];
    });
    
    return task;
}


- (void)finishTask:(NSURLSessionTask *)task
withResponseObject:(id)responseObject
             error:(NSError *)error
          userInfo:(NSMutableDictionary *)userInfo
 completionHandler:(void (^)(id JSONObject, NSError *error))completionHandler {
    
    if (userInfo && error) {
        userInfo[DSSessionManagerNotificationUserInfoKeyError] = error;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completionHandler(responseObject, error);
        [[NSNotificationCenter defaultCenter] postNotificationName:DSSessionManagerNotificationTaskFinished object:task userInfo:userInfo];
    });
}


#pragma mark - Network Tasks


- (void)cancelAllTasks {
    [self.URLSession invalidateAndCancel];
    self.URLSession = nil;
}


- (NSURLSessionDataTask *)startLoginInformationTaskWithCompletionHandler:(void (^)(DSLoginInformationResponse *response, NSError *error))completionHandler {
    NSAssert([self authHeaders], @"Authentication credentials not provided."); // other calls will check isAuthenticated property, this is an exception because it is required for login
    NSParameterAssert(completionHandler);
    
    return [self startDataTaskToGETRelativeURLString:@"login_information?api_password=true"
                                     queryDictionary:nil
                                       responseClass:[DSLoginInformationResponse class]
                                   completionHandler:completionHandler];
}


- (NSURLSessionDataTask *)startSigningURLTaskForRecipientWithID:(NSString *)recipientID
                                                         userID:(NSString *)userID
                                                   clientUserID:(NSString *)clientUserID
                                               inEnvelopeWithID:(NSString *)envelopeID
                                                      returnURL:(NSURL *)returnURL
                                              completionHandler:(void (^)(NSString *signingURLString, NSError *error))completionHandler {
    NSAssert(self.isAuthenticated, @"Call -[DSSessionManager authenticate] before starting additional tasks.");
    NSParameterAssert(recipientID);
    NSParameterAssert(envelopeID);
    NSParameterAssert(returnURL);
    NSParameterAssert(completionHandler);
    
    NSString *relativeURLString = [[NSString alloc] initWithFormat:@"accounts/%@/envelopes/%@/views/recipient", self.account.accountID, envelopeID];
    
    NSDictionary *requestDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       returnURL.absoluteString, @"returnUrl",
                                       userID ?: self.account.userID, @"userId",
                                       recipientID, @"recipientId",
                                       @"password", @"authenticationMethod",
                                       clientUserID, @"clientUserId", nil];
    return [self startDataTaskWithMethod:@"POST"
                       relativeURLString:relativeURLString
                                bodyData:[requestDictionary ds_JSONData] // not sure about authenticationMethod but currently it is required - PLAT-1973
                           responseClass:nil
                       completionHandler:^(id JSONObject, NSError *error) {
                           if (error) {
                               completionHandler(nil, error);
                           } else {
                               NSString *signingURLString = [JSONObject[@"url"] stringByReplacingOccurrencesOfString:@"Member" withString:@"signing"];
                               signingURLString = [signingURLString stringByAppendingString:@"&platform=ios&version=1"];
                               completionHandler(signingURLString, nil);
                           }
                       }];
}


- (NSURLSessionDataTask *)startCreateSelfSignEnvelopeTaskWithFileName:(NSString *)fileName
                                                              fileURL:(NSURL *)fileURL
                                                    completionHandler:(void (^)(DSCreateEnvelopeResponse *response, NSError *error))completionHandler {
    NSAssert(self.isAuthenticated, @"Call -[DSSessionManager authenticate] before starting additional tasks.");
    NSParameterAssert(fileURL);
    NSParameterAssert(completionHandler);
    
    if (!fileName) {
        fileName = [fileURL lastPathComponent];
    }
    
    NSAssert([fileURL isFileURL], @"fileURL must be a URL to a file");
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path], @"fileURL must point to a path which exists");
    NSAssert([fileName length] > 0, @"fileName required");
    NSAssert([[fileName pathExtension] length] > 0, @"fileExtension required");
        
    NSString *relativeURLString = [[NSString alloc] initWithFormat:@"accounts/%@/envelopes", self.account.accountID];
    return [self startDataTaskWithMethod:@"POST"
                       relativeURLString:relativeURLString
                                bodyData:[@{ @"emailSubject" : fileName,
                                             @"status"       : DSStringFromEnvelopeStatus(DSEnvelopeStatusDraft),
                                             @"recipients"   : @{ @"signers": @[ @{ @"name"         : self.account.userName,
                                                                                    @"email"        : self.account.email,
                                                                                    @"recipientId"  : @"1",
                                                                                    @"routingOrder" : @"1" } ] } } ds_JSONData]
                           responseClass:[DSCreateEnvelopeResponse class]
                       completionHandler:^(DSCreateEnvelopeResponse *createEnvelopeResponse, NSError *error) {
                           if (error) {
                               completionHandler(nil, error);
                               return;
                           }
                           [self startUploadDocumentTaskWithFileName:fileName
                                                             fileURL:fileURL
                                                          documentID:@"1"
                                                          envelopeID:createEnvelopeResponse.envelopeID
                                                   completionHandler:^(id JSONObject, NSError *error) {
                                                       if (error) {
                                                           completionHandler(nil, error);
                                                           return;
                                                       }
                                                       [self startSendDraftEnvelopeTaskWithEnvelopeID:createEnvelopeResponse.envelopeID
                                                                                    completionHandler:^(id JSONObject, NSError *error) {
                                                                                        if (error) {
                                                                                            completionHandler(nil, error);
                                                                                            return;
                                                                                        }
                                                                                        completionHandler(createEnvelopeResponse, nil);
                                                                                    }];
                                                   }];
                       }];
}


- (NSURLSessionDataTask *)startUploadDocumentTaskWithFileName:(NSString *)fileName
                                                      fileURL:(NSURL *)fileURL
                                                   documentID:(NSString *)documentID
                                                   envelopeID:(NSString *)envelopeID
                                          completionHandler:(void (^)(id JSONObject, NSError *error))completionHandler {
    NSAssert(self.isAuthenticated, @"Call -[DSSessionManager authenticate] before starting additional tasks.");
    NSParameterAssert(fileURL);
    NSParameterAssert(documentID);
    NSParameterAssert(envelopeID);
    NSParameterAssert(completionHandler);
    
    if (!fileName) {
        fileName = [fileURL lastPathComponent];
    }
    NSString *fileExtension = [fileName pathExtension];
    
    NSAssert([fileURL isFileURL], @"fileURL must be a URL to a file");
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path], @"fileURL must point to a path which exists");
    NSAssert([fileName length] > 0, @"fileName required");
    NSAssert([fileExtension length] > 0, @"fileExtension required");
    
    NSString *contentDisposition = [[NSString alloc] initWithFormat:@"file; filename=%@; documentid=%@; fileExtension=%@", fileName, documentID, fileExtension];
    
    NSString *relativeURLString = [[NSString alloc] initWithFormat:@"accounts/%@/envelopes/%@/documents/%@", self.account.accountID, envelopeID, documentID];
    return [self startDataTaskWithMethod:@"PUT"
                       relativeURLString:relativeURLString
                         queryDictionary:nil
                                bodyData:nil
                              bodyStream:[[NSInputStream alloc] initWithURL:fileURL]
                       additionalHeaders:@{ @"Content-Type" : [fileURL ds_mimeType],
                                            @"Content-Disposition" : contentDisposition }
                           responseClass:nil
                       completionHandler:completionHandler];
}


- (NSURLSessionDataTask *)startSendDraftEnvelopeTaskWithEnvelopeID:(NSString *)envelopeID
                                            completionHandler:(void (^)(id JSONObject, NSError *error))completionHandler {
    NSAssert(self.isAuthenticated, @"Call -[DSSessionManager authenticate] before starting additional tasks.");
    NSParameterAssert(envelopeID);
    NSParameterAssert(completionHandler);
    
    NSString *relativeURLString = [[NSString alloc] initWithFormat:@"accounts/%@/envelopes/%@", self.account.accountID, envelopeID];
    return [self startDataTaskWithMethod:@"PUT"
                       relativeURLString:relativeURLString
                                bodyData:[@{ @"status" : DSStringFromEnvelopeStatus(DSEnvelopeStatusSent) } ds_JSONData]
                           responseClass:nil
                       completionHandler:completionHandler];
}


- (NSURLSessionDataTask *)startEnvelopesListTaskWithLogicalGrouping:(DSLogicalEnvelopeGroup)logicalGroup
                                                              range:(NSRange)range
                                                           fromDate:(NSDate *)fromDate
                                                             toDate:(NSDate *)toDate
                                                  includeRecipients:(BOOL)includeRecipients
                                                  completionHandler:(void (^)(DSEnvelopesListResponse *response, NSError *error))completionHandler {
    NSAssert(self.isAuthenticated, @"Call -[DSSessionManager authenticate] before starting additional tasks.");
    NSAssert(range.length <= 100, @"Maximum number of envelopes is 100");
    NSParameterAssert(completionHandler);
    
    NSMutableDictionary *queryDictionary = [[NSMutableDictionary alloc] init];
    [queryDictionary setObject:@(range.location) forKey:@"start_position"];
    [queryDictionary setObject:@(range.length) forKey:@"count"];
    [queryDictionary setObject:@"DESC" forKey:@"order"];
    if (!fromDate) {
        fromDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:0];
        [queryDictionary setObject:[self.dateFormatter stringFromDate:fromDate] forKey:@"from_date"];
    }
    if (toDate) {
        NSAssert([toDate timeIntervalSinceDate:fromDate] > 0, @"fromDate must precede toDate");
        [queryDictionary setObject:[self.dateFormatter stringFromDate:toDate] forKey:@"to_date"];
    }
    if (includeRecipients) {
        [queryDictionary setObject:@"true" forKey:@"include_recipients"];
    }
    NSString *orderByString;
    switch (logicalGroup) {
        case DSLogicalEnvelopeGroupDrafts:
            orderByString = @"created";
            break;
        case DSLogicalEnvelopeGroupAwaitingASignature:
            orderByString = @"sent";
            break;
        case DSLogicalEnvelopeGroupAwaitingMySignature:
            orderByString = @"sent";
            break;
        case DSLogicalEnvelopeGroupCompleted:
            orderByString = @"completed";
            break;
    }
    [queryDictionary setObject:orderByString forKey:@"order_by"];
    
    NSString *relativeURLString = [[NSString alloc] initWithFormat:@"accounts/%@/search_folders/%@", self.account.accountID, DSStringFromLogicalEnvelopeGroup(logicalGroup)];
    return [self startDataTaskToGETRelativeURLString:relativeURLString
                                     queryDictionary:queryDictionary
                                       responseClass:[DSEnvelopesListResponse class]
                                   completionHandler:completionHandler];
}


- (NSURLSessionDataTask *)startEnvelopeDetailsTaskForEnvelopeWithID:(NSString *)envelopeID
                                                  completionHandler:(void (^)(DSEnvelopeDetailsResponse *response, NSError *error))completionHandler {
    NSAssert(self.isAuthenticated, @"Call -[DSSessionManager authenticate] before starting additional tasks.");
    NSParameterAssert(envelopeID);
    NSParameterAssert(completionHandler);
    
    NSString *relativeURLString = [[NSString alloc] initWithFormat:@"accounts/%@/envelopes/%@", self.account.accountID, envelopeID];
    return [self startDataTaskToGETRelativeURLString:relativeURLString
                                     queryDictionary:nil
                                       responseClass:[DSEnvelopeDetailsResponse class]
                                   completionHandler:completionHandler];
}



- (NSURLSessionDataTask *)startEnvelopeRecipientsTaskForEnvelopeWithID:(NSString *)envelopeID
                                                     completionHandler:(void (^)(DSEnvelopeRecipientsResponse *response, NSError *error))completionHandler {
    NSAssert(self.isAuthenticated, @"Call -[DSSessionManager authenticate] before starting additional tasks.");
    NSParameterAssert(envelopeID);
    NSParameterAssert(completionHandler);
    
    NSString *relativeURLString = [[NSString alloc] initWithFormat:@"accounts/%@/envelopes/%@/recipients", self.account.accountID, envelopeID];
    return [self startDataTaskToGETRelativeURLString:relativeURLString
                                     queryDictionary:nil
                                       responseClass:[DSEnvelopeRecipientsResponse class]
                                   completionHandler:completionHandler];
}

- (NSURLSessionDownloadTask *)startDownloadCompletedDocumentTaskForEnvelopeWithID:(NSString *)envelopeID
                                                               destinationFileURL:(NSURL *)destinationFileURL
                                                                completionHandler:(void (^)(NSError *error))completionHandler {
    NSAssert(self.isAuthenticated, @"Call -[DSSessionManager authenticate] before starting additional tasks.");
    NSParameterAssert(envelopeID);
    NSParameterAssert(destinationFileURL);
    NSParameterAssert(completionHandler);
    
    NSAssert([destinationFileURL isFileURL], @"destinationFileURL must be a URL to a file");
    NSAssert([[[destinationFileURL pathExtension] lowercaseString] isEqualToString:@"pdf"], @"destinationFileURL must include the file name and have a pdf extension");

    NSString *relativeURLString = [[NSString alloc] initWithFormat:@"accounts/%@/envelopes/%@/documents/combined", self.account.accountID, envelopeID];
    
    return [self startDownloadTaskWithMethod:@"GET"
                           relativeURLString:relativeURLString
                             queryDictionary:nil
                             responseFileURL:destinationFileURL
                           completionHandler:completionHandler];
}


- (NSURLSessionDataTask *)startRecipientSignatureCreateTaskForRecipientID:(NSString *)recipientID
                                                         inEnvelopeWithID:(NSString *)envelopeID
                                                                    image:(UIImage *)image
                                                            signaturePart:(DSSignaturePart)signaturePart
                                                        completionHandler:(void (^)(NSError *error))completionHandler {
    NSAssert(self.isAuthenticated, @"Call -[DSSessionManager authenticate] before starting additional tasks.");
    NSParameterAssert(recipientID);
    NSParameterAssert(envelopeID);
    NSParameterAssert(image);
    NSParameterAssert(completionHandler);
    
    NSString *partString = signaturePart == DSSignaturePartSignature ? @"signature_image" : @"initials_image";
    NSString *relativeURLString = [[NSString alloc] initWithFormat:@"accounts/%@/envelopes/%@/recipients/%@/%@", self.account.accountID, envelopeID, recipientID, partString];
    NSDictionary *contentTypeHeader = @{ @"Content-Type" : @"image/png" };
    return [self startDataTaskWithMethod:@"PUT"
                       relativeURLString:relativeURLString
                         queryDictionary:nil
                                bodyData:UIImagePNGRepresentation(image)
                              bodyStream:nil
                       additionalHeaders:contentTypeHeader
                           responseClass:nil
                       completionHandler:^(id JSONObject, NSError *error) {
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}


- (NSURLSessionDataTask *)startSignatureDeleteTaskForSignatureWithID:(NSString *)signatureID
                                                   completionHandler:(void (^)(NSError *error))completionHandler {
    NSAssert(self.isAuthenticated, @"Call -[DSSessionManager authenticate] before starting additional tasks.");
    NSParameterAssert(signatureID);
    NSParameterAssert(completionHandler);
    
    NSString *relativeURLString = [[NSString alloc] initWithFormat:@"accounts/%@/users/%@/signatures/%@", self.account.accountID, self.account.userID, signatureID];
    
    return [self startDataTaskWithMethod:@"DELETE"
                       relativeURLString:relativeURLString
                                bodyData:nil
                           responseClass:nil
                       completionHandler:^(id JSONObject, NSError *error) {
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}


- (NSURLSessionDataTask *)startSignaturesTaskWithCompletionHandler:(void (^)(DSUserSignaturesResponse *response, NSError *))completionHandler {
    NSAssert(self.isAuthenticated, @"Call -[DSSessionManager authenticate] before starting additional tasks.");
    NSParameterAssert(completionHandler);
    
    NSString *relativeURLString = [[NSString alloc] initWithFormat:@"accounts/%@/users/%@/signatures", self.account.accountID, self.account.userID];
    return [self startDataTaskToGETRelativeURLString:relativeURLString
                                     queryDictionary:nil
                                       responseClass:[DSUserSignaturesResponse class]
                                   completionHandler:completionHandler];
}


- (NSURLSessionDataTask *)startRecipientSignatureDetailsTaskForRecipientID:(NSString *)recipientID
                                                          inEnvelopeWithID:(NSString *)envelopeID
                                                         completionHandler:(void (^)(DSUserSignature *response, NSError *))completionHandler {
    NSAssert(self.isAuthenticated, @"Call -[DSSessionManager authenticate] before starting additional tasks.");
    NSParameterAssert(recipientID);
    NSParameterAssert(envelopeID);
    NSParameterAssert(completionHandler);
    
    NSString *relativeURLString = [[NSString alloc] initWithFormat:@"accounts/%@/envelopes/%@/recipients/%@/signature", self.account.accountID, envelopeID, recipientID];
    return [self startDataTaskToGETRelativeURLString:relativeURLString
                                     queryDictionary:nil
                                       responseClass:[DSUserSignature class]
                                   completionHandler:completionHandler];
}


#pragma mark - Signing


- (DSSigningViewController *)signingViewControllerForRecipientWithID:(NSString *)recipientID inEnvelopeWithID:(NSString *)envelopeID delegate:(id<DSSigningViewControllerDelegate>)delegate {
    NSAssert(self.isAuthenticated, @"Call -[DSSessionManager authenticate] before starting additional tasks.");

    NSParameterAssert(envelopeID);
    NSParameterAssert(delegate);
    
    return [[DSSigningViewController alloc] initWithEnvelopeID:envelopeID
                                                   recipientID:recipientID
                                                sessionManager:self
                                                      delegate:delegate];
}


#pragma mark - Logging


- (DSNetworkLogger *)logger {
    if (!_logger) {
        _logger = [[DSNetworkLogger alloc] initWithLogOptions:AKANetworkLoggerOptionsOff];
    }
    return _logger;
}


@end
