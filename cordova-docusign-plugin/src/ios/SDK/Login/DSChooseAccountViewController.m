//
//  DSChooseAccountViewController.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/9/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSChooseAccountViewController.h"

#import "DSStoryboardFactory.h"

#import "DSLoginAccount.h"


@interface DSChooseAccountViewController () <UITableViewDataSource, UITabBarDelegate>

@property (nonatomic) NSArray *accounts;

@end


@implementation DSChooseAccountViewController


#pragma mark - Lifecycle


- (instancetype)initWithAccounts:(NSArray *)accounts delegate:(id<DSChooseAccountViewControllerDelegate>)delegate {
    self = [[[DSStoryboardFactory sharedStoryboardFactory] loginStoryboard] instantiateViewControllerWithIdentifier:@"DSChooseAccountViewController"];
    if (!self) {
        return nil;
    }
    
    _accounts = accounts;
    _delegate = delegate;
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - 


- (DSLoginAccount *)accountAtIndexPath:(NSIndexPath *)indexPath {
    return self.accounts[indexPath.row];
}


#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.accounts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const SubtitleCell = @"SubtitleCell";
    
    DSLoginAccount *account = [self accountAtIndexPath:indexPath];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SubtitleCell forIndexPath:indexPath];
    
    cell.textLabel.text = account.accountName;
    cell.detailTextLabel.text = account.userName;
    
    return cell;
}


#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DSLoginAccount *account = [self accountAtIndexPath:indexPath];
    [self.delegate chooseAccountViewController:self didChooseAccount:account];
}


@end
