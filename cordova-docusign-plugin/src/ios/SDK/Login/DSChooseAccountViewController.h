//
//  DSChooseAccountViewController.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/9/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DSChooseAccountViewController, DSLoginAccount;

@protocol DSChooseAccountViewControllerDelegate <NSObject>

- (void)chooseAccountViewController:(DSChooseAccountViewController *)controller didChooseAccount:(DSLoginAccount *)account;
- (void)chooseAccountViewControllerCancelled:(DSChooseAccountViewController *)controller;

@end


@interface DSChooseAccountViewController : UITableViewController

@property (nonatomic, readonly) NSArray *accounts;
@property (nonatomic, weak) id<DSChooseAccountViewControllerDelegate> delegate;

- (instancetype)initWithAccounts:(NSArray *)accounts delegate:(id<DSChooseAccountViewControllerDelegate>)delegate;

@end
