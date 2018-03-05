//
//  CalculatorButton.m
//  Calculator Pro
//
//  Created by Lucas Popp on 9/29/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import "CalculatorButton.h"

@interface CalculatorButton ()

@property (strong, nonatomic) UIView *backgroundManager;
@property (strong, nonatomic) UIView *backgroundTouchShadow;

@property (strong, nonatomic) UIImageView *settingsImage;

@property (strong, nonatomic) NSMutableArray *stateIndicators;

@end

@implementation CalculatorButton

- (void)unifiedInit {
    self.buttonState = CalculatorButtonStateNormal;
    
    self.backgroundManager = [[UIView alloc] initWithFrame:self.bounds];
    
    [self addSubview:self.backgroundManager];
    [self sendSubviewToBack:self.backgroundManager];
    
    self.backgroundTouchShadow = [[UIView alloc] initWithFrame:self.backgroundManager.bounds];
    
    self.backgroundTouchShadow.backgroundColor = [UIColor blackColor];
    self.backgroundTouchShadow.alpha = 0.0f;
    
    [self.backgroundManager addSubview:self.backgroundTouchShadow];
    
    CGSize imageSize = CGSizeMake(21.0f, 21.0f);
    
    self.settingsImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - imageSize.width) / 2.0f, (self.frame.size.height - imageSize.height) / 2.0f, imageSize.width, imageSize.height)];
    self.settingsImage.image = [[UIImage imageNamed:@"Settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.settingsImage.tintColor = [UIColor whiteColor];
    self.settingsImage.hidden = YES;
    [self.backgroundManager addSubview:self.settingsImage];
    
    self.stateIndicators = [[NSMutableArray alloc] init];
    
    _style = CalculatorButtonStyleDark;
    [self styleButtonAnimated:NO];
    self.backgroundManager.userInteractionEnabled = NO;
}

- (id)init {
    if (self == [super init]) {
        [self unifiedInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self unifiedInit];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    if (self.buttonState == CalculatorButtonStateNormal) {
        [self setTitle:self.title forState:UIControlStateNormal];
    }
}

- (void)setSecondTitle:(NSString *)secondTitle {
    _secondTitle = secondTitle;
    
    if (self.buttonState == CalculatorButtonStateSecond) {
        [self setTitle:self.secondTitle forState:UIControlStateNormal];
    }
}

- (void)setThirdTitle:(NSString *)thirdTitle {
    _thirdTitle = thirdTitle;
    
    if (self.buttonState == CalculatorButtonStateThird) {
        [self setTitle:self.thirdTitle forState:UIControlStateNormal];
    }
}

- (void)setButtonState:(CalculatorButtonState)buttonState {
    _buttonState = buttonState;
    
    [self styleButtonAnimated:YES];
}

- (void)setStyle:(CalculatorButtonStyle)style {
    _style = style;
    
    [self styleButtonAnimated:YES];
}

- (void)styleButton {
    [self styleButtonAnimated:NO];
}

- (void)styleButtonAnimated:(BOOL)animated {
    UIColor *normalColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    UIColor *secondColor = [UIColor colorWithRed:1.0f green:0.2f blue:0.2f alpha:1.0f];
    UIColor *thirdColor = [UIColor colorWithRed:0.2f green:0.2f blue:1.0f alpha:1.0f];
    
    CalculatorButtonState stateToDisplay = self.buttonState;
    
    if (![self hasTitleForState:self.buttonState]) {
        stateToDisplay = CalculatorButtonStateNormal;
    }
    
    UIFont *font = [UIFont boldSystemFontOfSize:[UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize];
    UIColor *backgroundColor = normalColor;
    UIColor *textColor = [UIColor whiteColor];
    NSString *newTitle = @"";
    
    switch (stateToDisplay) {
        case CalculatorButtonStateNormal:
            newTitle = self.title;
            
            self.enabled = !self.normalDisabled;
            
            switch (self.style) {
                case CalculatorButtonStyleDark:
                    backgroundColor = normalColor;
                    textColor = [UIColor whiteColor];
                    break;
                    
                case CalculatorButtonStyleGrey:
                    backgroundColor = [UIColor colorWithWhite:0.3f alpha:1.0f];
                    textColor = [UIColor whiteColor];
                    break;
                    
                case CalculatorButtonStyleLight:
                    backgroundColor = [UIColor whiteColor];
                    textColor = [UIColor blackColor];
                    font = [UIFont boldSystemFontOfSize:[UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize + 2.0f];
                    break;
                    
                case CalculatorButtonStyleSecond:
                    backgroundColor = secondColor;
                    textColor = [UIColor whiteColor];
                    break;
                    
                case CalculatorButtonStyleThird:
                    backgroundColor = thirdColor;
                    textColor = [UIColor whiteColor];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case CalculatorButtonStateSecond:
            newTitle = self.secondTitle;
            textColor = [UIColor whiteColor];
            
            self.enabled = !self.secondDisabled;
            
            switch (self.style) {
                case CalculatorButtonStyleSecond:
                    backgroundColor = normalColor;
                    break;
                    
                case CalculatorButtonStyleThird:
                    backgroundColor = thirdColor;
                    break;
                    
                default:
                    backgroundColor = secondColor;
                    break;
            }
            
            break;
            
        case CalculatorButtonStateThird:
            newTitle = self.thirdTitle;
            textColor = [UIColor whiteColor];
            
            self.enabled = !self.thirdDisabled;
            
            switch (self.style) {
                case CalculatorButtonStyleSecond:
                    backgroundColor = secondColor;
                    break;
                    
                case CalculatorButtonStyleThird:
                    backgroundColor = normalColor;
                    break;
                    
                default:
                    backgroundColor = thirdColor;
                    break;
            }
            
            break;
            
        default:
            break;
    }
    
    if (self.stateIndicators) {
        for (UIView *subview in self.stateIndicators) {
            [subview removeFromSuperview];
        }
        
        [self.stateIndicators removeAllObjects];
        
        if (self.appearance == CalculatorButtonAppearanceDot) {
            CGSize indicatorSize = CGSizeMake(4.0f, 4.0f);
            
            if ([self hasTitleForState:CalculatorButtonStateSecond] && ![self.secondTitle isEqual:@"2ND"]) {
                UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(4.0f, 4.0f, indicatorSize.width, indicatorSize.height)];
                indicatorView.layer.cornerRadius = indicatorSize.width / 2.0f;
                
                if (stateToDisplay != CalculatorButtonStateSecond) {
                    indicatorView.backgroundColor = secondColor;
                }
                
                [self.stateIndicators addObject:indicatorView];
                [self addSubview:indicatorView];
            }
            
            if ([self hasTitleForState:CalculatorButtonStateThird] && ![self.thirdTitle isEqual:@"3RD"]) {
                UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(4.0f + (indicatorSize.width * 1.5f * (float)self.stateIndicators.count), 4.0f, indicatorSize.width, indicatorSize.height)];
                indicatorView.layer.cornerRadius = indicatorSize.width / 2.0f;
                
                if (stateToDisplay != CalculatorButtonStateThird) {
                    indicatorView.backgroundColor = thirdColor;
                }
                
                [self.stateIndicators addObject:indicatorView];
                [self addSubview:indicatorView];
            }
        } else if (self.appearance == CalculatorButtonAppearanceFull) {
            if ([self hasTitleForState:CalculatorButtonStateSecond] && ![self.secondTitle isEqual:@"2ND"]) {
                UILabel *secondIndicator = [[UILabel alloc] initWithFrame:CGRectMake(4.0f, 4.0f, self.frame.size.width - 8.0f, 14.0f)];
                
                secondIndicator.textAlignment = NSTextAlignmentLeft;
                
                if (stateToDisplay != CalculatorButtonStateSecond) {
                    secondIndicator.text = self.secondTitle;
                    secondIndicator.textColor = secondColor;
                }
                
                if ([secondIndicator.text isEqual:@"CLEAR\nALL"]) {
                    secondIndicator.text = @"CA";
                }
                
                secondIndicator.font = self.titleLabel.font;
                
                CGFloat pointSize = secondIndicator.font.pointSize;
                
                [secondIndicator sizeToFit];
                
                while (secondIndicator.frame.size.height > 14.0f) {
                    pointSize -= 0.05f;
                    
                    secondIndicator.font = [secondIndicator.font fontWithSize:pointSize];
                    
                    [secondIndicator sizeToFit];
                }
                
                secondIndicator.frame = CGRectMake(4.0f, 4.0f, self.frame.size.width - 8.0f, 14.0f);
                
                secondIndicator.lineBreakMode = NSLineBreakByWordWrapping;
                secondIndicator.numberOfLines = [secondIndicator.text componentsSeparatedByString:@"\n"].count;
                
                [self.stateIndicators addObject:secondIndicator];
                [self addSubview:secondIndicator];
            }
            
            if ([self hasTitleForState:CalculatorButtonStateThird] && ![self.thirdTitle isEqual:@"3RD"]) {
                if ([self.thirdIdentifier isEqual:@"settings"]) {
                    if (stateToDisplay != CalculatorButtonStateThird) {
                        UIImageView *thirdIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 10.0f - 4.0f, 4.0f, 10.0f, 10.0f)];
                        thirdIndicator.image = [[UIImage imageNamed:@"Settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        thirdIndicator.tintColor = thirdColor;
                        
                        [self.stateIndicators addObject:thirdIndicator];
                        [self addSubview:thirdIndicator];
                    }
                } else {
                    UILabel *thirdIndicator = [[UILabel alloc] initWithFrame:CGRectMake(4.0f, 4.0f, self.frame.size.width - 8.0f, 14.0f)];
                    
                    thirdIndicator.textAlignment = NSTextAlignmentRight;
                    
                    if (stateToDisplay != CalculatorButtonStateThird) {
                        thirdIndicator.text = self.thirdTitle;
                        thirdIndicator.textColor = thirdColor;
                    }
                    
                    thirdIndicator.font = self.titleLabel.font;
                    
                    CGFloat pointSize = thirdIndicator.font.pointSize;
                    
                    [thirdIndicator sizeToFit];
                    
                    while (thirdIndicator.frame.size.height > 14.0f) {
                        pointSize -= 0.05f;
                        
                        thirdIndicator.font = [thirdIndicator.font fontWithSize:pointSize];
                        
                        [thirdIndicator sizeToFit];
                    }
                    
                    thirdIndicator.frame = CGRectMake(4.0f, 4.0f, self.frame.size.width - 8.0f, 14.0f);
                    
                    thirdIndicator.lineBreakMode = NSLineBreakByWordWrapping;
                    thirdIndicator.numberOfLines = [thirdIndicator.text componentsSeparatedByString:@"\n"].count;
                    
                    [self.stateIndicators addObject:thirdIndicator];
                    [self addSubview:thirdIndicator];
                }
            }
        }
    }
    
    if (!self.enabled) {
        textColor = [textColor colorWithAlphaComponent:0.8f];
    }
    
    float animationTime = 0.0f;
    
    if (animated) {
        animationTime = 0.2f;
    }
    
    [UIView animateWithDuration:animationTime animations:^{
        self.titleLabel.font = font;
        self.backgroundManager.backgroundColor = backgroundColor;
        [self setTitleColor:textColor forState:UIControlStateNormal];
        
        self.settingsImage.hidden = YES;
        
        if ([newTitle isEqual:@"SETTINGS"]) {
            self.settingsImage.hidden = NO;
            [self setTitle:@"" forState:UIControlStateNormal];
        } else {
            [self setTitle:newTitle forState:UIControlStateNormal];
        }
        
        if (self.enabled) {
            self.backgroundTouchShadow.alpha = 0.0f;
        } else {
            self.backgroundTouchShadow.alpha = [self alphaForStyle:self.style];
        }
    }];
}

- (BOOL)hasTitleForState:(CalculatorButtonState)state {
    switch (state) {
        case CalculatorButtonStateNormal:
            return (![self.title isEqual:@""] && self.title != nil);
            
        case CalculatorButtonStateSecond:
            return (![self.secondTitle isEqual:@""] && self.secondTitle != nil);
            
        case CalculatorButtonStateThird:
            return (![self.thirdTitle isEqual:@""] && self.thirdTitle != nil);
            
        default:
            return NO;
    }
}

- (BOOL)hasIdentifierForState:(CalculatorButtonState)state {
    switch (state) {
        case CalculatorButtonStateNormal:
            return (![self.identifier isEqual:@""] && self.identifier != nil);
            
        case CalculatorButtonStateSecond:
            return (![self.secondIdentifier isEqual:@""] && self.secondIdentifier != nil);
            
        case CalculatorButtonStateThird:
            return (![self.thirdIdentifier isEqual:@""] && self.thirdIdentifier != nil);
            
        default:
            return NO;
    }
}

- (NSString *)currentText {
    CalculatorButtonState stateToDisplay = self.buttonState;
    
    if (![self hasTitleForState:self.buttonState]) {
        stateToDisplay = CalculatorButtonStateNormal;
    }
    
    switch (stateToDisplay) {
        case CalculatorButtonStateNormal:
            return self.text;
            
        case CalculatorButtonStateSecond:
            return self.secondText;
            
        case CalculatorButtonStateThird:
            return self.thirdText;
            
        default:
            return @"";
    }
}

- (NSString *)currentIdentifier {
    CalculatorButtonState stateToDisplay = self.buttonState;
    
    if (![self hasIdentifierForState:self.buttonState]) {
        stateToDisplay = CalculatorButtonStateNormal;
    }
    
    switch (stateToDisplay) {
        case CalculatorButtonStateNormal:
            return self.identifier;
            
        case CalculatorButtonStateSecond:
            return self.secondIdentifier;
            
        case CalculatorButtonStateThird:
            return self.thirdIdentifier;
            
        default:
            return @"";
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        [UIView animateWithDuration:0.1f animations:^{
            self.backgroundTouchShadow.alpha = [self alphaForStyle:self.style];
        }];
    } else {
        [UIView animateWithDuration:0.1f animations:^{
            self.backgroundTouchShadow.alpha = 0.0f;
        }];
    }
}

- (CGFloat)alphaForStyle:(CalculatorButtonStyle)style {
    switch (style) {
        case CalculatorButtonStyleDark:
            return 0.2f;
            
        case CalculatorButtonStyleGrey:
            return 0.15f;
            
        case CalculatorButtonStyleLight:
            return 0.1f;
            
        case CalculatorButtonStyleSecond:
            return 0.2f;
            
        case CalculatorButtonStyleThird:
            return 0.2f;
            
        default:
            return 0.0f;
    }
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    
    self.titleLabel.font = [self.titleLabel.font fontWithSize:[UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize];
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = [title componentsSeparatedByString:@"\n"].count;
    
    if ([title componentsSeparatedByString:@"\n"].count == 2 || ([title isEqual:@"WINDOW"] && self.buttonState == CalculatorButtonStateThird)) {
        self.titleLabel.font = [self.titleLabel.font fontWithSize:self.titleLabel.font.pointSize * (2.0f / 3.0f)];
    }
}

- (void)setAppearance:(CalculatorButtonAppearance)appearance {
    _appearance = appearance;
    
    [self styleButtonAnimated:YES];
}

- (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font {
    return [text boundingRectWithSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{
                                        NSFontAttributeName : font
                                        }
                              context:nil].size;
}

@end
