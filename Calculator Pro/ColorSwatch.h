//
//  ColorSwatch.h
//  Calculator Pro
//
//  Created by Lucas Popp on 10/23/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorSwatch : UIButton

@property (nonatomic, assign) BOOL swatchSelected;
@property (strong, nonatomic) UIColor *color;

- (id)initWithFrame:(CGRect)frame;
- (void)setColor:(UIColor *)color;
- (void)setFrame:(CGRect)frame;
- (void)setSwatchSelected:(BOOL)swatchSelected;

@end
