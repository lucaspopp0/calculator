//
//  AppearanceView.h
//  Calculator Pro
//
//  Created by Lucas Popp on 10/28/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorLine.h"

@interface AppearanceView : UIView

@property (strong, nonatomic) CalculatorLine *line;

- (void)prepare;

@end
