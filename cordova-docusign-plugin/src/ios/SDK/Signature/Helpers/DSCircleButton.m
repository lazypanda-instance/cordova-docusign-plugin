//
//  DSCircularRacistButton.h
//  DocuSignIt
//
//  Created by Stephen Parish on 9/20/13.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSCircleButton.h"
#import <QuartzCore/QuartzCore.h>

@interface DSCircleButton ()

@end

@implementation DSCircleButton

- (void)ds_circle_button_setup {
    UIColor *savedBackgroundColor = [self.backgroundColor copy];
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = self.bounds.size.height / 2;
    [self setBackgroundImage:nil forState:UIControlStateNormal];
    
    NSUInteger padding = 3;
    UIView *innerBackground = [[UIView alloc] initWithFrame:CGRectMake(padding, padding, self.bounds.size.width - padding * 2, self.bounds.size.height - padding * 2)];
    innerBackground.backgroundColor = savedBackgroundColor;
    innerBackground.layer.cornerRadius = innerBackground.bounds.size.height / 2;
    innerBackground.userInteractionEnabled = NO;
    innerBackground.exclusiveTouch = NO;
    [self addSubview:innerBackground];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    if (!self) {
        return nil;
    }

    [self ds_circle_button_setup];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (!self) {
        return nil;
    }
    
    [self ds_circle_button_setup];
    
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.backgroundColor = selected ? [UIColor colorWithWhite:0 alpha:0.5] : [UIColor clearColor];
}

@end
