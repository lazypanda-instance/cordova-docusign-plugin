//
//  SDDocuSign.m
//
//  Created by Lazy Panda Tech on 27/03/20.
//
//

#import "SDDocuSign.h"
#import "DSTableViewController.h"

@implementation SDDocuSign

- (void)launchDocuSignSDK:(CDVInvokedUrlCommand*)command
{
    
    
    NSString* callbackId = [command callbackId];
    NSString* name = [[command arguments] objectAtIndex:0];
    
    [self createPopUpView:name];
    
    NSString *message = @"Success";
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:message];
    
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void)createPopUpView:(NSString*)messageData {
    
    DSTableViewController *tableViewController = [[DSTableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.messageString = messageData;
    navController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    [self.viewController.view addSubview:navController.view];
}

@end
