//
//  CalculatorButton.h
//  Calculator Pro
//
//  Created by Lucas Popp on 9/29/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CalculatorButtonAppearanceNormal,
    CalculatorButtonAppearanceDot,
    CalculatorButtonAppearanceFull
} CalculatorButtonAppearance;

typedef enum {
    CalculatorButtonStateNormal,
    CalculatorButtonStateSecond,
    CalculatorButtonStateThird
} CalculatorButtonState;

typedef enum {
    CalculatorButtonStyleDark,
    CalculatorButtonStyleGrey,
    CalculatorButtonStyleLight,
    CalculatorButtonStyleSecond,
    CalculatorButtonStyleThird
} CalculatorButtonStyle;

@interface CalculatorButton : UIButton

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *secondTitle;
@property (strong, nonatomic) NSString *thirdTitle;

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *secondText;
@property (strong, nonatomic) NSString *thirdText;

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *secondIdentifier;
@property (strong, nonatomic) NSString *thirdIdentifier;

@property (nonatomic, assign) BOOL normalDisabled;
@property (nonatomic, assign) BOOL secondDisabled;
@property (nonatomic, assign) BOOL thirdDisabled;

@property (nonatomic, assign) CalculatorButtonState buttonState;
@property (nonatomic, assign) CalculatorButtonStyle style;

@property (nonatomic, assign) CalculatorButtonAppearance appearance;

- (id)init;
- (id)initWithFrame:(CGRect)frame;

- (void)setTitle:(NSString *)title;
- (void)setSecondTitle:(NSString *)secondTitle;
- (void)setThirdTitle:(NSString *)thirdTitle;
- (void)setButtonState:(CalculatorButtonState)buttonState;
- (void)setStyle:(CalculatorButtonStyle)style;
- (void)setHighlighted:(BOOL)highlighted;

- (NSString *)currentText;
- (NSString *)currentIdentifier;

- (void)setTitle:(NSString *)title forState:(UIControlState)state;

- (void)setAppearance:(CalculatorButtonAppearance)appearance;

@end
