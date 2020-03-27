//
//  DSSigningAPIManager.m
//  DocuSignIt
//
//  Created by Stephen Parish on 12/12/13.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSSigningAPIManager.h"

#import <CoreLocation/CoreLocation.h>

//#import <Mantle/Mantle.h>
#import "Mantle.h"

#import "DSSigningAPIDeclineOptions.h"
#import "DSSigningAPIDeclineSigning.h"
#import "DSSigningAPICanFinishChanged.h"
#import "DSSigningAPIConsumerDisclosure.h"
#import "DSSigningAPIAdoptSignatureTabDetails.h"
#import "DSSigningAPIAddCCRecipients.h"

#import "NSURL+DS_QueryDictionary.h"

static NSString * const DS_SIGNING_API_TABS[] = {
    @"null",
    @"'SignHere'",
    @"'InitialHere'",
    @"'FullName'",
    @"'DateSigned'",
    @"'TextMultiline'",
    @"'Checkbox'",
    @"'Company'",
    @"'Title'"
};

@interface DSSigningAPIManager() <CLLocationManagerDelegate, UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic) NSURL *messageURL;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL awaitingFirstMessage;

@end

@implementation DSSigningAPIManager

@dynamic ready;

#pragma mark - Lifecycle

- (instancetype)initWithWebView:(UIWebView *)webView messageURL:(NSURL *)messageURL andDelegate:(id<DSSigningAPIDelegate>)delegate {
    self = [super init];
    if (self) {
        _webView = webView;
        webView.delegate = self;
        _messageURL = messageURL;
        _delegate = delegate;
        [self startJavaScriptBridge];
    }
    return self;
}

- (void)dealloc {
    [self stopMonitoringLocation];
}

- (BOOL)isReady {
    return !self.awaitingFirstMessage;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSDictionary *queryParameters = [request.URL ds_queryDictionary];
    NSString *messageId = queryParameters[@"messageId"];
    NSString *messageData = queryParameters[@"data"];
    NSString *event = queryParameters[@"event"];
    if ([messageId length] > 0) {
        [self handleMessage:messageId data:messageData];
        return NO;
    } else if ([event length] > 0) {
        [self handleEvent:event];
        return NO;
    } else if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self startJavaScriptBridge];
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:webView didFailLoadWithError:error];
    }
}

#pragma mark -

- (void)startJavaScriptBridge {
    if ([[self.webView stringByEvaluatingJavaScriptFromString:@"DSSigning !== undefined"] boolValue]) {
        self.awaitingFirstMessage = YES;
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:
             @"DSSigning.init({"
             @"    sendMessage: function(id, data) {"
             @"        var iframe = document.createElement('iframe');"
             @"        var src = '%@?messageId=' + id + '&data=' + encodeURIComponent(JSON.stringify(data || {}));"
             @"        iframe.setAttribute('src', src);"
             @"        document.documentElement.appendChild(iframe);"
             @"        iframe.parentNode.removeChild(iframe);"
             @"        iframe = null;"
             @"    },"
             @"    suppress: {"
             @"        addCCRecipientsDialog: false"
             @"    }"
             @"});", [self.messageURL absoluteString]]];
    }
}

- (void)handleMessage:(NSString *)messageId data:(NSString *)data {
    NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonParseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonParseError];
    
    // handle message is sometimes enters here from another thread
    // make sure all delegate calls here are passed back in the main
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.awaitingFirstMessage) {
            self.awaitingFirstMessage = NO;
            [self.delegate signingIsReady:self];
        }

        if (!jsonParseError && jsonDictionary) {
            if ([messageId isEqualToString:@"acceptConsumerDisclosureRequested"]) {
                DSSigningAPIConsumerDisclosure *disclosure = [self consumerDisclosure];
                
                [self.delegate signing:self didRequestConsumerDisclosureConsent:disclosure]; // TODO: for some reason the disclosure I get has all blank properties, the string is just {}
            } else if ([messageId isEqualToString:@"canFinishChanged"]) {
                DSSigningAPICanFinishChanged *canFinishChanged = [MTLJSONAdapter modelOfClass:[DSSigningAPICanFinishChanged class]
                                                                           fromJSONDictionary:jsonDictionary
                                                                                        error:nil];
                self.canFinish = canFinishChanged.canFinish;
                [self.delegate signing:self canFinishChanged:canFinishChanged.canFinish];
            } else if ([messageId isEqualToString:@"adoptSignatureRequested"]) {
                DSSigningAPIAdoptSignatureTabDetails *details = [MTLJSONAdapter modelOfClass:[DSSigningAPIAdoptSignatureTabDetails class]
                                                                          fromJSONDictionary:jsonDictionary[@"tab"]
                                                                                       error:nil];
                [self.delegate signing:self didRequestSignature:details];
            } else if ([messageId isEqualToString:@"geoLocationRequested"]) {
                [self startMonitoringLocation];
                [self locationManager:self.locationManager didUpdateLocations:[[NSArray alloc] initWithObjects:self.locationManager.location, nil]];
            } else if ([messageId isEqualToString:@"applyFormFieldsRequested"]) {
                [self.delegate signingFoundFormFields:self];
            } else if ([messageId isEqualToString:@"inPersonSignerEmailRequested"]) {
                [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"DSSigning.setInPersonSignerEmail('%@')", self.inPersonSignerEmail ?: @""]];
            } else if ([messageId isEqualToString:@"declineRequested"]) {
                [self.delegate signing:self didRequestDecline:[MTLJSONAdapter modelOfClass:[DSSigningAPIDeclineOptions class]
                                                                        fromJSONDictionary:jsonDictionary
                                                                                     error:nil]];
            } else if ([messageId isEqualToString:@"addCCRecipientsRequested"]) {
                [self.delegate signing:self didRequestCarbonCopies:[MTLJSONAdapter modelOfClass:[DSSigningAPIAddCCRecipients class]
                                                                             fromJSONDictionary:jsonDictionary
                                                                                          error:nil]];
            } else if ([messageId isEqualToString:@"error"]) {
                [self.delegate signing:self didFailWithErrorMessage:jsonDictionary[@"value"]];
            }
        }
    });
}

- (void)handleEvent:(NSString *)event {
    if ([event isEqualToString:@"cancel"]) {
        [self.delegate signingDidCancel:self];
    } else if ([event isEqualToString:@"decline"]) {
        [self.delegate signingDidDecline:self];
    } else if ([event isEqualToString:@"exception"]) {
        [self.delegate signing:self didFailWithErrorMessage:@"An error occurred."];
    } else if ([event isEqualToString:@"fax_pending"]) {
        [self.delegate signing:self didFailWithErrorMessage:@"Recipient has fax pending. Unsupported."];
    } else if ([event isEqualToString:@"id_check_failed"]) {
        [self.delegate signing:self didFailWithErrorMessage:@"ID check failed."];
    } else if ([event isEqualToString:@"session_timeout"]) {
        [self.delegate signingDidTimeout:self];
    } else if ([event isEqualToString:@"signing_complete"]) {
        [self.delegate signingDidComplete:self];
    } else if ([event isEqualToString:@"ttl_expired"]) {
        [self.delegate signingDidTimeout:self];
    } else if ([event isEqualToString:@"viewing_complete"]) {
        [self.delegate signingDidViewEnvelope:self];
    } else if ([event isEqualToString:@"access_code_failed"]) {
        [self.delegate signing:self didFailWithErrorMessage:@"Access code failed."];
    } else {
        [self.delegate signing:self didFailWithErrorMessage:@"Unknown redirect received."];
    }
}

#pragma mark - JSON Helpers

- (NSDictionary *)dictionaryByEvaluatingJavaScriptFromString:(NSString *)string {
    NSString *cmd = [NSString stringWithFormat:
                     @"( function() {"
                     @"  var result = %@;"
                     @"  result = result instanceof Object ? JSON.stringify(result) : (result || '{}');"
                     @"  return result;"
                     @"})()", string];
    NSString *jsonString = [self.webView stringByEvaluatingJavaScriptFromString:cmd];
    NSError *jsonParseError;
    return [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonParseError];
}

#pragma mark - Signing Lifecycle

- (void)saveSigning {
    [self.webView stringByEvaluatingJavaScriptFromString:@"DSSigning.save()"];
}

- (void)cancelSigning {
    [self.webView stringByEvaluatingJavaScriptFromString:@"DSSigning.exit()"];
}

- (BOOL)finishSigning {
    NSDictionary *finishResult = [self dictionaryByEvaluatingJavaScriptFromString:@"DSSigning.finish()"];
    return [finishResult[@"finished"] boolValue];
}

#pragma mark - Carbon Copy Recipients

- (DSSigningAPIAddCCRecipients *)carbonCopyRecipientAddingOptions {
    NSDictionary *dictionary = [self dictionaryByEvaluatingJavaScriptFromString:@"DSSigning.getAddCCRecipientsOptions()"];
    return [MTLJSONAdapter modelOfClass:[DSSigningAPIAddCCRecipients class]
                     fromJSONDictionary:dictionary
                                  error:nil];
}

- (void)addCarbonCopyRecipients:(DSSigningAPIAddCCRecipients *)carbonCopyRecipients {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"DSSigning.addCCRecipients(%@)", [MTLJSONAdapter JSONDictionaryFromModel:carbonCopyRecipients]]];
}

#pragma mark - Consumer Disclosure

- (DSSigningAPIConsumerDisclosure *)consumerDisclosure {
    NSDictionary *dictionary = [self dictionaryByEvaluatingJavaScriptFromString:@"DSSigning.getConsumerDisclosure()"];
    return [MTLJSONAdapter modelOfClass:[DSSigningAPIConsumerDisclosure class]
                     fromJSONDictionary:dictionary
                                  error:nil];
}

- (void)acceptConsumerDisclosure {
    [self.webView stringByEvaluatingJavaScriptFromString:@"DSSigning.setConsumerDisclosureAccepted(true)"];
}

#pragma mark - Decline

- (BOOL)canDecline {
    return [[self dictionaryByEvaluatingJavaScriptFromString:@"DSSigning.getDeclineOptions()"] count] > 0;
}

- (DSSigningAPIDeclineOptions *)declineOptions {
    NSDictionary *dictionary = [self dictionaryByEvaluatingJavaScriptFromString:@"DSSigning.getDeclineOptions()"];
    return [MTLJSONAdapter modelOfClass:[DSSigningAPIDeclineOptions class]
                     fromJSONDictionary:dictionary
                                  error:nil];
}

- (void)declineSigningWithDetails:(DSSigningAPIDeclineSigning *)details {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"DSSigning.decline(%@)", [MTLJSONAdapter JSONDictionaryFromModel:details]]];
}

#pragma mark - Signature

- (void)adoptSignature:(NSString *)signatureImageId {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"DSSigning.adoptSignature({signatureGuid:'%@'});", signatureImageId]];
}

- (void)adoptInitials:(NSString *)initialsImageId {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"DSSigning.adoptSignature({initialsGuid:'%@'});", initialsImageId]];
}

- (void)cancelAdoptSignatureOrInitials {
    [self.webView stringByEvaluatingJavaScriptFromString:@"DSSigning.adoptSignature();"];
}

#pragma mark - Navigate Document

- (void)autoNavigate {
    [self.webView stringByEvaluatingJavaScriptFromString:@"DSSigning.autoNavigate()"];
}

- (void)scrollToNextPage {
    [self.webView stringByEvaluatingJavaScriptFromString:@"DSSigning.navigateToNextPage()"];
}

- (void)scrollToPreviousPage {
    [self.webView stringByEvaluatingJavaScriptFromString:@"DSSigning.navigateToPreviousPage()"];
}

- (void)scrollToPage:(NSInteger)page {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"DSSigning.setCurrentPage(%ld)", (long)page]];
}

- (NSInteger)pageCount {
    return [[self.webView stringByEvaluatingJavaScriptFromString:@"DSSigning.getPageCount()"] integerValue];
}

- (NSInteger)currentPageNumber {
    return [[self.webView stringByEvaluatingJavaScriptFromString:@"DSSigning.getCurrentPage()"] integerValue];
}

#pragma mark - Page Rotation

- (void)rotatePageLeft {
    [self.webView stringByEvaluatingJavaScriptFromString:@"DSSigning.rotatePage('left')"];
}

- (void)rotatePageRight {
    [self.webView stringByEvaluatingJavaScriptFromString:@"DSSigning.rotatePage('right')"];
}

#pragma mark - Hosted Signing

#pragma mark - Tags

- (void)setSelectedFreeformTab:(DSSigningAPITab)selectedFreeformTab {
    NSString *tabType = DS_SIGNING_API_TABS[selectedFreeformTab];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"DSSigning.setSelectedFreeformTabType(%@)", tabType]];
    _selectedFreeformTab = selectedFreeformTab;
}

- (BOOL)isFreeform {
    return [[self.webView stringByEvaluatingJavaScriptFromString:@"DSSigning.isFreeformEnabled()"] boolValue];
}

- (DSSigningAPIAdoptSignatureTabDetails *)currentSignatureTabDetails {
    NSDictionary *dictionary = [self dictionaryByEvaluatingJavaScriptFromString:@"DSSigning.getAdoptSignatureTabDetails()"];
    return [MTLJSONAdapter modelOfClass:[DSSigningAPIAdoptSignatureTabDetails class]
                     fromJSONDictionary:dictionary
                                  error:nil];
}

- (void)applyFormFields:(BOOL)apply {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"DSSigning.applyFormFields(%@)", apply ? @"true" : @"false"]];
}

#pragma mark - CLLocationManagerDelegate

- (void)startMonitoringLocation {
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager significantLocationChangeMonitoringAvailable]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void)stopMonitoringLocation {
    [self.locationManager stopMonitoringSignificantLocationChanges];
    self.locationManager.delegate = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    if (newLocation.horizontalAccuracy < 0) {
        return; // do not send invalid location data
    }
    NSString *position = [NSString stringWithFormat:@"{coords:{accuracy:%f,altitude:%@,altitudeAccuracy:%@,heading:%@,latitude:%f,longitude:%f,speed:%@}}", // docs incorrect, see SIGN-2817
                          newLocation.horizontalAccuracy,
                          (newLocation.verticalAccuracy < 0)   ? @"null" : [NSString stringWithFormat:@"%f", newLocation.altitude],
                          (newLocation.verticalAccuracy < 0)   ? @"null" : [NSString stringWithFormat:@"%f", newLocation.verticalAccuracy],
                          (newLocation.course < 0)             ? @"null" : [NSString stringWithFormat:@"%f", newLocation.course],
                          newLocation.coordinate.latitude,
                          newLocation.coordinate.longitude,
                          (newLocation.speed < 0)              ? @"null" : [NSString stringWithFormat:@"%f", newLocation.speed]];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"DSSigning.setGeoLocation(%@);", position]];
}

@end
