//
//  DSFinePrintViewController.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/6/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSFinePrintViewController : UIViewController

@property (nonatomic, readonly) NSString *HTMLContent;

- (instancetype)initWithHTMLContent:(NSString *)HTMLContent;

@end
