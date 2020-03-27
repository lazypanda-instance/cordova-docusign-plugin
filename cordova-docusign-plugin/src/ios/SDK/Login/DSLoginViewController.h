//
//  DSLoginViewController.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/9/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DSRestAPIEnvironment.h"

@class DSLoginViewController, DSSessionManager;

@protocol DSLoginViewControllerDelegate <NSObject>

- (void)loginViewController:(DSLoginViewController *)controller didLoginWithSessionManager:(DSSessionManager *)sessionManager;
- (void)loginViewControllerCancelled:(DSLoginViewController *)controller;

@end

@interface DSLoginViewController : UIViewController

@property (nonatomic, weak) id<DSLoginViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *userNameMessage;
@property (nonatomic, strong) NSString *userPasswordMessage;

- (instancetype)initWithIntegratorKey:(NSString *)integratorKey forEnvironment:(DSRestAPIEnvironment)environment delegate:(id<DSLoginViewControllerDelegate>)delegate;

- (instancetype)initWithIntegratorKey:(NSString *)integratorKey forEnvironment:(DSRestAPIEnvironment)environment email:(NSString *)email delegate:(id<DSLoginViewControllerDelegate>)delegate;

@end
