//
//  CustomTextField.h
//  Calculator Pro
//
//  Created by Lucas Popp on 10/15/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTextField : UITextField

- (void)insertText:(NSString *)text;
- (void)backOne;
- (void)deletePressed;

- (id)init;
- (id)initWithFrame:(CGRect)frame;

- (int)cursorPosition;
- (void)setCursorIndex:(int)index;
- (void)setSelectedTextRange:(UITextRange *)selectedTextRange;

- (void)setText:(NSString *)text;

@end
