//
//  SDDocuSign.h
//  ChildSupport
//
//  Created by Sudipta Das on 14/01/16.
//
//

//#import <Cordova/Cordova.h>
#import <Cordova/CDVPlugin.h>

@interface SDDocuSign : CDVPlugin
{
    UINavigationController *navController;
}

- (void) launchDocuSignSDK:(CDVInvokedUrlCommand*)command;

@end
