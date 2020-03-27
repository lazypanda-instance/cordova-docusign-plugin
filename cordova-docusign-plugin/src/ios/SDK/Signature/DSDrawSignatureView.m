//
//  DSDrawSignatureView.m
//  DocuSignIt
//
//  Created by Arlo Armstrong on 4/10/12.
//  Copyright (c) 2012 DocuSign, Inc. All rights reserved.
//

#import "DSDrawSignatureView.h"
#import <QuartzCore/QuartzCore.h>

@interface DSDrawSignatureView ()  {
@private
    CGPoint currentPoint;
    CGPoint previousPoint1;
    CGPoint previousPoint2;
}

@end


static NSUInteger const LENGTH_LIMIT = 8;
static CGFloat const CLAMP_MAX = 6;
static CGFloat const CLAMP_MIN = 1.5;
static CGFloat const SPEED_MULTIPLIER = 500;

CGPoint midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

CGFloat distanceBetweenPoints(CGPoint p1, CGPoint p2) {
    return sqrt(pow((p2.x - p1.x), 2.0) + pow((p2.y - p1.y), 2.0));
}

CGFloat clamp(CGFloat value, CGFloat max, CGFloat min) {
    CGFloat result = value;
    if (value > max) {
        result = max;
    } else if (value < min) {
        result = min;
    }
    return result;
}

@interface NSMutableArray (averages)

- (CGFloat)meanValue;
- (void)addObject:(id)anObject lengthLimit:(NSUInteger)limit;

@end

@interface DSDrawSignatureView () 

@property (nonatomic) BOOL clearOnRedraw;
@property (nonatomic, strong) UIImage *currentImage;
@property (nonatomic, strong) UIImage *nextImage;
@property (nonatomic, strong) NSDate *lastTouch;
@property (nonatomic, strong) NSMutableArray *touchSpeeds;

@end

@implementation DSDrawSignatureView

- (void)awakeFromNib {
    self.touchSpeeds = [NSMutableArray arrayWithCapacity:LENGTH_LIMIT];
    self.lineColor = [UIColor blackColor];
    self.empty = YES;
    [self initializeTouchSpeeds];
}

- (void)initializeTouchSpeeds {
    [self.touchSpeeds removeAllObjects];
    CGFloat initValue = ((CLAMP_MAX - CLAMP_MIN) * 0.5) + CLAMP_MIN;
    for (NSUInteger i = 0; i < LENGTH_LIMIT; i++) {
        [self.touchSpeeds addObject:[NSNumber numberWithFloat:initValue] lengthLimit:LENGTH_LIMIT];
    }
}

- (void)setFixedLineWidth:(BOOL)fixed {
    self.lineWidth = 3;
    self.fixedWidth = fixed;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (!self.fixedWidth) {
        [self initializeTouchSpeeds];
        self.lastTouch = [NSDate date];
    }
    UITouch *touch = [touches anyObject];
    
    previousPoint1 = [touch previousLocationInView:self];
    previousPoint2 = [touch previousLocationInView:self];
    currentPoint = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self renderTouchToScreen:[touches anyObject]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self renderTouchToScreen:[touches anyObject]];
}

- (void)renderTouchToScreen:(UITouch *)touch {
    previousPoint2  = previousPoint1;
    previousPoint1  = [touch previousLocationInView:self];
    currentPoint    = [touch locationInView:self];
    
    if (!self.fixedWidth) {
        NSDate *currentTouch = [NSDate date];
        NSTimeInterval timeInterval = [currentTouch timeIntervalSinceDate:self.lastTouch];
        CGFloat distance = distanceBetweenPoints(currentPoint, previousPoint1);
        CGFloat speed = distance/timeInterval;
        CGFloat clampedSpeed = clamp(SPEED_MULTIPLIER/speed, CLAMP_MAX, CLAMP_MIN);
        [self.touchSpeeds addObject:[NSNumber numberWithFloat:clampedSpeed] lengthLimit:LENGTH_LIMIT];
        self.lineWidth = [self.touchSpeeds meanValue];
        self.lastTouch = currentTouch;
    }
    // calculate mid point
    CGPoint mid1    = midPoint(previousPoint1, previousPoint2); 
    CGPoint mid2    = midPoint(currentPoint, previousPoint1);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(path, NULL, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y);
    CGRect bounds = CGPathGetBoundingBox(path);
    CGPathRelease(path);
    
    CGRect drawBox = bounds;
    
    //Pad our values so the bounding box respects our line width
    drawBox.origin.x        -= self.lineWidth * 2;
    drawBox.origin.y        -= self.lineWidth * 2;
    drawBox.size.width      += self.lineWidth * 4;
    drawBox.size.height     += self.lineWidth * 4;
    
    UIGraphicsBeginImageContextWithOptions(drawBox.size, YES, 0.0);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIGraphicsEndImageContext();
    self.empty = NO;
    [self setNeedsDisplayInRect:drawBox];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.clearOnRedraw) {
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        
        // draw the filled rectangle
        CGContextFillRect (context, self.bounds);
        self.clearOnRedraw = NO;
        if (self.nextImage) {
            [self.nextImage drawInRect:self.bounds];
            self.empty = NO;
            self.nextImage = nil;
        }
    } else {
        CGPoint mid1 = midPoint(previousPoint1, previousPoint2); 
        CGPoint mid2 = midPoint(currentPoint, previousPoint1);
        
        [self.layer renderInContext:context];
        
        CGContextMoveToPoint(context, mid1.x, mid1.y);
        // Use QuadCurve is the key
        CGContextAddQuadCurveToPoint(context, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y); 
        
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        
        CGContextStrokePath(context);
    }
}

- (void)clear {
    self.empty = YES;
    self.clearOnRedraw = YES;
    [self setNeedsDisplay];
}

- (UIImage *)getImage {
    if (self.empty) {
        return nil;
    }
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (void)setImage:(UIImage *)image {
    self.nextImage = image;
    [self clear];
}

@end

@implementation NSMutableArray (averages)

- (CGFloat)meanValue {
    CGFloat result = 0;
    for (NSNumber *num in self) {
        result += [num floatValue];
    }
    return result/[self count];
}

- (void)addObject:(id)anObject lengthLimit:(NSUInteger)limit {
    [self addObject:anObject];
    if ([self count] > limit) {
        [self removeObjectAtIndex:0];
    }
}

@end
