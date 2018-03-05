//
//  CustomTextField.m
//  Calculator Pro
//
//  Created by Lucas Popp on 10/15/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (void)unifiedInit {
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    self.inputView = dummyView;
    self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.spellCheckingType = UITextSpellCheckingTypeNo;
}

- (id)init {
    if (self == [super init]) {
        [self unifiedInit];
    }
    
    return self;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    
    if ([text rangeOfString:@"ERR"].location != NSNotFound) {
        [self.superview setValue:@(YES) forKey:@"isError"];
    }
}

- (id)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self unifiedInit];
    }
    
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 8.0f, 0.0f);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (void)insertText:(NSString *)text {
    [super insertText:text];
}

- (void)deletePressed {
    [self deleteBackward];
}

- (void)backOne {
    [self setSelectedTextRange:[self textRangeFromPosition:[self positionFromPosition:self.selectedTextRange.start offset:-1] toPosition:[self positionFromPosition:self.selectedTextRange.start offset:-1]]];
}

- (int)cursorPosition {
    return (int)[self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
}

- (void)setCursorIndex:(int)index {
    [self setSelectedTextRange:[self textRangeFromPosition:[self positionFromPosition:self.beginningOfDocument offset:index] toPosition:[self positionFromPosition:self.beginningOfDocument offset:index]]];
}

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    if (self.enabled) {
        [super setSelectedTextRange:[self textRangeFromPosition:selectedTextRange.start toPosition:selectedTextRange.start]];
    } else {
        [super setSelectedTextRange:selectedTextRange];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.enabled) {
        if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            if (((UITapGestureRecognizer *)gestureRecognizer).numberOfTapsRequired == 2) {
                return NO;
            }
        }
    }
    
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    
    return NO;
}

@end
