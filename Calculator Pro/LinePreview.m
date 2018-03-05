//
//  LinePreview.m
//  Calculator Pro
//
//  Created by Lucas Popp on 10/23/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import "LinePreview.h"
#import <QuartzCore/QuartzCore.h>

@implementation LinePreview

- (id)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        self.dashed = NO;
        self.thickness = 1.5f;
        self.color = [UIColor colorWithWhite:0.2f alpha:1.0f];
        
        self.clipsToBounds = NO;
    }
    
    return self;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}

- (void)setThickness:(float)thickness {
    _thickness = thickness;
    [self setNeedsDisplay];
}

- (void)setDashed:(BOOL)dashed {
    _dashed = dashed;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, self.bounds);
    
    [[UIColor whiteColor] setFill];
    
    CGContextFillRect(context, self.bounds);
    
    [self.color setStroke];
    
    if (self.dashed) {
        CGFloat dash[] = {2.0f, 2.0f};
        CGContextSetLineDash(context, 0.0f, dash, 2);
    } else {
        CGContextSetLineDash(context, 0.0f, nil, 0);
    }
    
    CGContextSetLineWidth(context, (float)self.thickness);
    
    CGContextMoveToPoint(context, 0.0f, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0.0f);
    CGContextStrokePath(context);
}

@end
