//
//  DSTableViewController.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 4/22/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSTableViewController.h"

#import "DocuSign-iOS-SDK.h"

NSString * const DSTableViewControllerIntegratorKey = @"DEMO-9289fb18-583a-4ffc-9d98-a42cdb588a40";
DSRestAPIEnvironment const DSTableViewControllerEnvironment = DSRestAPIEnvironmentDemo;
NSString * const DSTableViewControllerEmail = @""; // optional


NSInteger const DSTableViewControllerAlertViewTagCompleted = 1;


@interface DSTableViewController () <UITableViewDataSource, UITableViewDelegate, DSLoginViewControllerDelegate, DSSigningViewControllerDelegate, UIAlertViewDelegate>

//@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadBarButton;

@property (nonatomic) DSSessionManager *sessionManager;
@property (nonatomic) NSArray *envelopes; // DSEnvelopesListEnvelope

@property (nonatomic) NSString *completedEnvelopeID;

@end


@implementation DSTableViewController

@synthesize messageString = _messageString;


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    uploadButton.frame = CGRectMake(0, 0, 200, 30);
    [uploadButton setTitle:@"Upload New Document" forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(uploadDocumentTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *closeDocuSignBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    closeDocuSignBtn.frame = CGRectMake(0, 0, 100, 30);
    [closeDocuSignBtn setTitle:@"Close" forState:UIControlStateNormal];
    [closeDocuSignBtn addTarget:self action:@selector(closeDocuSign) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *uploadBarButton = [[UIBarButtonItem alloc] initWithCustomView:uploadButton];
    UIBarButtonItem *closeDocuSignbarBtn = [[UIBarButtonItem alloc] initWithCustomView:closeDocuSignBtn];
    self.navigationItem.rightBarButtonItem = uploadBarButton;
    self.navigationItem.leftBarButtonItem = closeDocuSignbarBtn;
    
    NSArray *messageArray = [_messageString componentsSeparatedByString:@","];
    userName = [messageArray objectAtIndex:0];
    userPassword = [messageArray objectAtIndex:1];
    uploadedFileName = [messageArray objectAtIndex:2];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self.sessionManager isAuthenticated]) {
        DSLoginViewController *loginViewController = [[DSLoginViewController alloc] initWithIntegratorKey:DSTableViewControllerIntegratorKey forEnvironment:DSTableViewControllerEnvironment email:DSTableViewControllerEmail delegate:self];
        loginViewController.userNameMessage = userName;
        loginViewController.userPasswordMessage = userPassword;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navController animated:YES completion:nil];
    }
}


#pragma mark - User Interaction

- (void)closeDocuSign {
    [self.navigationController.view removeFromSuperview];
}


- (IBAction)refreshControlValueChanged:(id)sender {
    [self fetchData];
}


- (void)uploadDocumentTapped:(id)sender {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if(uploadedFileName.length != 0) {
        
        NSURL *filePathUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:uploadedFileName ofType:@"pdf" inDirectory:@"www/assets"]];
        
        [self.sessionManager startCreateSelfSignEnvelopeTaskWithFileName:nil
                                                                 fileURL: filePathUrl
                                                       completionHandler:^(DSCreateEnvelopeResponse *response, NSError *error)
         {
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             if (error) {
                 [[[UIAlertView alloc] initWithTitle:@"Error Upload Document" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];                                                           return;
             }
             DSSigningViewController *signingViewController = [self.sessionManager signingViewControllerForRecipientWithID:nil
                                                                                                          inEnvelopeWithID:response.envelopeID
                                                                                                                  delegate:self];
             UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:signingViewController];
             [self presentViewController:navController animated:YES completion:nil];
         }];
    }
    
    
}


#pragma mark - 


- (DSEnvelopesListEnvelope *)envelopeAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.envelopes count] == 0) {
        return nil;
    }
    return self.envelopes[indexPath.row];
}


- (void)fetchData {
    [self.refreshControl beginRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.sessionManager startEnvelopesListTaskWithLogicalGrouping:DSLogicalEnvelopeGroupAwaitingMySignature
                                                             range:NSMakeRange(0, 20)
                                                          fromDate:nil
                                                            toDate:nil
                                                 includeRecipients:YES
                                                 completionHandler:^(DSEnvelopesListResponse *response, NSError *error) {
                                                     [self.refreshControl endRefreshing];
                                                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                     if (error) {
                                                         [[[UIAlertView alloc] initWithTitle:@"Error Fetching Envelopes" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                                     }
                                                     self.envelopes = response.envelopes; // this list sometimes contains duplicates. See PLAT-2092
                                                     [self.tableView reloadData];
                                                 }];
}


#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX([self.envelopes count], 1);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    static NSString * const SubtitleCell = @"SubtitleCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SubtitleCell forIndexPath:indexPath];
    
    DSEnvelopesListEnvelope *envelope = [self envelopeAtIndexPath:indexPath];

    if (envelope) {
        cell.textLabel.text = envelope.emailSubject;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Sent by %@ on %@", envelope.senderName, [NSDateFormatter localizedStringFromDate:envelope.sentDateTime dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.textLabel.text = @"No envelopes.";
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
     */
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    //cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    
    DSEnvelopesListEnvelope *envelope = [self envelopeAtIndexPath:indexPath];
    
    if (envelope) {
        cell.textLabel.text = envelope.emailSubject;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Sent by %@ on %@", envelope.senderName, [NSDateFormatter localizedStringFromDate:envelope.sentDateTime dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.textLabel.text = @"No envelopes.";
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.envelopes count] > 0 ? indexPath : nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DSEnvelopesListEnvelope *envelope = [self envelopeAtIndexPath:indexPath];
    DSEnvelopeRecipient *recipient = [[[envelope.recipients allSigners] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(DSEnvelopeRecipient *aRecipient, NSDictionary *bindings) {
        return [aRecipient.userID isEqualToString:self.sessionManager.account.userID];
    }]] firstObject];
    
    if (!recipient) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Unable to Sign" message:@"No envelope recipients match the logged in user." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    DSSigningViewController *signingViewController = [self.sessionManager signingViewControllerForRecipientWithID:recipient.recipientID
                                                                                                 inEnvelopeWithID:envelope.envelopeID
                                                                                                         delegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:signingViewController];
    [self presentViewController:navController animated:YES completion:nil];
}


#pragma mark - DSLoginViewControllerDelegate


- (void)loginViewController:(DSLoginViewController *)controller didLoginWithSessionManager:(DSSessionManager *)sessionManager {
    sessionManager.logger.logOptions = AKANetworkLoggerOptionsInfoLevel;
    
    self.sessionManager = sessionManager;
    [self dismissViewControllerAnimated:YES completion:^{
        [self fetchData];
    }];
}


- (void)loginViewControllerCancelled:(DSLoginViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - DSSigningViewControllerDelegate


- (void)signingViewController:(DSSigningViewController *)signingViewController completedWithStatus:(DSSigningCompletedStatus)status {
    self.completedEnvelopeID = signingViewController.envelopeID;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self fetchData];
        NSString *message;
        NSString *otherButtonTitle;
        switch (status) {
            case DSSigningCompletedStatusSigned: {
                message = @"Download completed document?";
                otherButtonTitle = @"Download";
                break;
            }
            case DSSigningCompletedStatusDeferred:
                message = @"Don't forget to sign later.";
                break;
            case DSSigningCompletedStatusDeclined:
                message = @"Signing declined :(";
                break;
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Returned from Signing" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:otherButtonTitle, nil];
        alertView.tag = DSTableViewControllerAlertViewTagCompleted;
        [alertView show];
    }];
}


- (void)signingViewController:(DSSigningViewController *)signingViewController failedWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{
        [self fetchData];
        [[[UIAlertView alloc] initWithTitle:@"Signing Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}


#pragma mark - UIAlertViewDelegate


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    if (alertView.tag == DSTableViewControllerAlertViewTagCompleted) {
        NSString *destinationPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:self.completedEnvelopeID] stringByAppendingPathExtension:@"pdf"];
        [self.sessionManager startDownloadCompletedDocumentTaskForEnvelopeWithID:self.completedEnvelopeID
                                                              destinationFileURL:[NSURL fileURLWithPath:destinationPath]
                                                               completionHandler:^(NSError *error) {
                                                                   NSString *downloadMessage = error.localizedDescription;
                                                                   if (!downloadMessage) {
                                                                       downloadMessage = [[NSString alloc] initWithFormat:@"File path:%@", destinationPath];
                                                                   }
                                                                   [[[UIAlertView alloc] initWithTitle:@"Download Finished" message:downloadMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                                               }];
    }
}


@end
