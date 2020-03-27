//
//  DSEnvelopesListResponse.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/8/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSRestAPIResponseModel.h"

@interface DSEnvelopesListResponse : DSRestAPIResponseModel

@property (nonatomic) NSInteger  resultSetSize;
@property (nonatomic) NSInteger  totalSetSize;
@property (nonatomic) NSInteger  startPosition;
@property (nonatomic) NSInteger  endPosition;
@property (nonatomic) NSURL     *nextURL;
@property (nonatomic) NSURL     *previousURL;
@property (nonatomic) NSArray   *envelopes; // DSEnvelopesListEnvelope

@end
