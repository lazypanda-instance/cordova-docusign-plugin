//
//  DSCondition+DSCommon.h
//  DSTextEntryValidation
//
//  Created by Arlo Armstrong on 5/14/14.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSCondition.h"


@interface DSCondition (DSCommon)

+ (DSCondition *)notBlankCondition;
+ (DSCondition *)conditionWithMinLength:(NSUInteger)length;
+ (DSCondition *)conditionWithMaxLength:(NSUInteger)length;
+ (DSCondition *)noSpacesCondition;
+ (DSCondition *)alphanumericCondition;
+ (DSCondition *)validURLCondition;

@end
