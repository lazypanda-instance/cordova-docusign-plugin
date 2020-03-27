//
//  DSNetworkLogger.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 4/28/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSNetworkLogger.h"

#import "DSSessionManager.h"

@implementation DSNetworkLogger

- (NSString *)nameForNetworkTaskStartNotification {
    return DSSessionManagerNotificationTaskStarted;
}

- (NSString *)nameForNetworkTaskFinishNotification {
    return DSSessionManagerNotificationTaskFinished;
}

- (NSData *)dataFromNetworkNotification:(NSNotification *)notification {
    return notification.userInfo[DSSessionManagerNotificationUserInfoKeyData];
}

- (NSError *)errorFromNetworkNotification:(NSNotification *)notification {
    NSError *result = [super errorFromNetworkNotification:notification];
    if (!result) {
        result = notification.userInfo[DSSessionManagerNotificationUserInfoKeyError];
    }
    return result;
}

- (void)outputLogString:(NSString *)string {
#ifdef DEBUG
    [super outputLogString:string];
#endif
}

@end
