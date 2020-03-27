//
//  DSDrawSignatureView.h
//  DocuSignIt
//
//  Created by Arlo Armstrong on 4/10/12.
//  Copyright (c) 2012 DocuSign, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSDrawSignatureView : UIView

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) BOOL fixedWidth;
@property (nonatomic, getter = isEmpty) BOOL empty;

- (void)setFixedLineWidth:(BOOL)fixed;
- (void)clear;
- (UIImage *)getImage;
- (void)setImage:(UIImage *)image;

@end
