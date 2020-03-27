//
//  DSFinePrintViewController.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/6/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSFinePrintViewController.h"


@interface DSFinePrintViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic) NSString *HTMLContent;
@property (nonatomic) BOOL contentLoaded;

@end


@implementation DSFinePrintViewController


- (instancetype)initWithHTMLContent:(NSString *)HTMLContent {
    self = [super init];
    if (!self) {
        return nil;
    }
    _HTMLContent = HTMLContent;
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Doing Business Electronically";
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.delegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.contentLoaded) {
        [self.webView loadHTMLString:self.HTMLContent baseURL:nil];
    }
}


#pragma mark - UIWebViewDelegate


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.contentLoaded = YES;
    [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.contentLoaded = YES;
}


@end
