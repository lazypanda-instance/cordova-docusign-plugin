//
//  DSTableViewController.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 4/22/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSTableViewController : UITableViewController
{
    NSString *userName;
    NSString *userPassword;
    NSString *uploadedFileName;
}

@property (nonatomic, strong) NSString *messageString;

@end
