//
//  DSValidatedTextFieldCell.h
//  DSTextEntryValidation
//
//  Created by Arlo Armstrong on 5/14/14.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSValidatedTextField.h"


@interface DSValidatedTextFieldCell : UITableViewCell


@property (weak, nonatomic) IBOutlet DSValidatedTextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *label;


@end
