//
//  CalculatorLine.m
//  Calculator Pro
//
//  Created by Lucas Popp on 10/15/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import "CalculatorLine.h"

@interface CalculatorLine () <UITextFieldDelegate>

@property (nonatomic) CGFloat topOffset;

@end

@implementation CalculatorLine

- (id)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        self.textField = [[CustomTextField alloc] init];
        self.textField.delegate = self;
        [self addSubview:self.textField];
        [self.textField becomeFirstResponder];
        
        self.prefixLabel = [[UILabel alloc] init];
        self.prefixLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.prefixLabel];
        
        self.appearanceButton = [[UIButton alloc] init];
        self.preview = [[LinePreview alloc] initWithFrame:self.appearanceButton.bounds];
        self.preview.userInteractionEnabled = NO;
        [self.appearanceButton addSubview:self.preview];
        [self addSubview:self.appearanceButton];
        
        self.frame = self.frame;
        self.isOutput = NO;
        
        self.lineColor = [UIColor colorWithRed:1.0f green:0.2f blue:0.2f alpha:1.0f];
        self.lineThickness = 1.5f;
        self.lineDashed = NO;
        
        self.showsAppearanceEditor = NO;
        
        self.reciever = [[UIButton alloc] initWithFrame:self.bounds];
        [self addSubview:self.reciever];
        [self sendSubviewToBack:self.reciever];
    }
    
    return self;
}

- (void)setPrefix:(NSString *)prefix {
    _prefix = prefix;
    self.prefixLabel.text = self.prefix;
    [self setFrame:self.frame];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    float x = 0.0f;
    float width = self.frame.size.width;
    
    self.appearanceButton.hidden = !self.showsAppearanceEditor;
    
    if (self.showsAppearanceEditor) {
        x += self.frame.size.height - 8.0f;
        width -= self.frame.size.height;
        self.appearanceButton.frame = CGRectMake(0.0f, 0.0f, self.frame.size.height, self.frame.size.height);
        
        CGRect buttonFrame = self.appearanceButton.bounds;
        buttonFrame.origin.x = (buttonFrame.size.width - 16.0f) / 2.0f;
        buttonFrame.origin.y = (buttonFrame.size.height - 16.0f) / 2.0f;
        buttonFrame.size.width = 16.0f;
        buttonFrame.size.height = 16.0f;
        
        self.preview.frame = buttonFrame;
    }
    
    if (self.prefix == nil || [self.prefix isEqual:@""]) {
        self.prefixLabel.hidden = YES;
    } else {
        self.prefixLabel.hidden = NO;
        self.prefixLabel.frame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
        [self.prefixLabel sizeToFit];
        self.prefixLabel.frame = CGRectMake(x + 8.0f, self.topOffset, self.prefixLabel.frame.size.width, self.frame.size.height - self.topOffset);
        x = self.prefixLabel.frame.origin.x + self.prefixLabel.frame.size.width - 8.0f;
        width = self.frame.size.width - (self.prefixLabel.frame.origin.x + self.prefixLabel.frame.size.width) - 8.0f;
    }
    
    self.textField.frame = CGRectMake(x, self.topOffset, width, self.frame.size.height - self.topOffset);
}

- (void)setIsOutput:(BOOL)isOutput {
    _isOutput = isOutput;
    
    if (self.isOutput) {
        self.textField.textAlignment = NSTextAlignmentRight;
    } else {
        self.textField.textAlignment = NSTextAlignmentLeft;
    }
}

- (void)setIsTappable:(BOOL)isTappable {
    _isTappable = (isTappable && !self.isError);
    
    if (self.isTappable && !self.isError) {
        [self bringSubviewToFront:self.reciever];
        [self sendSubviewToBack:self.textField];
    } else {
        [self sendSubviewToBack:self.reciever];
        [self bringSubviewToFront:self.textField];
    }
}

- (void)setIsError:(BOOL)isError {
    _isError = isError;
    
    if (isError) {
        self.isTappable = NO;
        self.textField.textColor = [UIColor colorWithRed:1.0f green:0.2f blue:0.2f alpha:1.0f];
    } else {
        self.textField.textColor = [UIColor blackColor];
    }
}

- (void)setShowsAppearanceEditor:(BOOL)showsAppearanceEditor {
    _showsAppearanceEditor = showsAppearanceEditor;
}

- (void)setLineColor:(UIColor *)lineColor {
    if (self.lineColor != lineColor) {
        self.changed = YES;
    }
    
    _lineColor = lineColor;
    self.preview.color = self.lineColor;
}

- (void)setLineDashed:(BOOL)lineDashed {
    if (self.lineDashed != lineDashed) {
        self.changed = YES;
    }
    
    _lineDashed = lineDashed;
    self.preview.dashed = self.lineDashed;
}

- (void)setLineThickness:(float)lineThickness {
    if (self.lineThickness != lineThickness) {
        self.changed = YES;
    }
    
    _lineThickness = lineThickness;
    self.preview.thickness = self.lineThickness;
}

@end
