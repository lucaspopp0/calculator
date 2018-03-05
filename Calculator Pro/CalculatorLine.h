//
//  CalculatorLine.h
//  Calculator Pro
//
//  Created by Lucas Popp on 10/15/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"
#import "LinePreview.h"

@interface CalculatorLine : UIView

@property (nonatomic, assign) BOOL isOutput;

@property (nonatomic) BOOL changed;

@property (strong, nonatomic) UIButton *reciever;

@property (strong, nonatomic) CustomTextField *textField;
@property (strong, nonatomic) UIButton *appearanceButton;
@property (strong, nonatomic) LinePreview *preview;
@property (strong, nonatomic) UILabel *prefixLabel;

@property (nonatomic, assign) BOOL isTappable;
@property (nonatomic, assign) BOOL isError;

@property (strong, nonatomic) NSString *prefix;

@property (strong, nonatomic) UIColor *lineColor;
@property (nonatomic) float lineThickness;
@property (nonatomic) BOOL lineDashed;

@property (nonatomic) BOOL showsAppearanceEditor;

- (void)setIsTappable:(BOOL)isTappable;
- (void)setIsError:(BOOL)isError;

- (id)initWithFrame:(CGRect)frame;
- (void)setFrame:(CGRect)frame;

- (void)setIsOutput:(BOOL)isOutput;

- (void)setPrefix:(NSString *)prefix;

- (void)setShowsAppearanceEditor:(BOOL)showsAppearanceEditor;

- (void)setLineColor:(UIColor *)lineColor;
- (void)setLineDashed:(BOOL)lineDashed;
- (void)setLineThickness:(float)lineThickness;

@end
