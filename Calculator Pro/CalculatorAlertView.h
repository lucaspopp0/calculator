//
//  CalculatorAlertView.h
//  Calculator Pro
//
//  Created by Lucas Popp on 10/17/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorAlertView : UIView

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIButton *titleButton;
@property (strong, nonatomic) UIView *bodyView;

@property (strong, nonatomic) UIButton *doneButton;

- (void)setTitle:(NSString *)title;
- (id)initWithTitle:(NSString *)title andView:(UIView *)bodyView;
- (void)setFrame:(CGRect)frame;

@end
