//
//  ColorSwatch.m
//  Calculator Pro
//
//  Created by Lucas Popp on 10/23/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import "ColorSwatch.h"
#import <QuartzCore/QuartzCore.h>

@interface ColorSwatch ()

@property (strong, nonatomic) UIView *swatch;
@property (nonatomic) float padding;

@end

@implementation ColorSwatch

- (id)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        self.padding = 4.0f;
        
        self.swatch = [[UIView alloc] init];
        [self setFrame:frame];
        self.swatchSelected = NO;
        [self addSubview:self.swatch];
        
        self.userInteractionEnabled = NO;
        self.swatch.userInteractionEnabled = NO;
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.swatch.frame = self.bounds;
    
    self.swatch.layer.cornerRadius = self.swatch.frame.size.width / 2.0f;
    
    if (self.swatchSelected) {
        self.swatch.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
    }
}

- (void)setSwatchSelected:(BOOL)swatchSelected {
    _swatchSelected = swatchSelected;
    
    if (self.swatchSelected) {
        [UIView animateWithDuration:0.15f animations:^{
            self.swatch.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
        }];
    } else {
        [UIView animateWithDuration:0.15f animations:^{
            self.swatch.transform = CGAffineTransformScale(CGAffineTransformIdentity, (self.bounds.size.width - (2.0f * self.padding)) / self.bounds.size.width, (self.bounds.size.height - (2.0f * self.padding)) / self.bounds.size.height);
        }];
    }
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.swatch.backgroundColor = self.color;
}

@end
