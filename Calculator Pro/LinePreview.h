//
//  LinePreview.h
//  Calculator Pro
//
//  Created by Lucas Popp on 10/23/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinePreview : UIView

@property (strong, nonatomic) UIColor *color;
@property (nonatomic) float thickness;
@property (nonatomic) BOOL dashed;

- (id)initWithFrame:(CGRect)frame;

- (void)setColor:(UIColor *)color;
- (void)setThickness:(float)thickness;
- (void)setDashed:(BOOL)dashed;

@end
