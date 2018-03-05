//
//  CalculatorAlertView.m
//  Calculator Pro
//
//  Created by Lucas Popp on 10/17/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import "CalculatorAlertView.h"
#import <QuartzCore/QuartzCore.h>

@interface CalculatorAlertView ()

@property (strong, nonatomic) UIView *contentView;

@end

@implementation CalculatorAlertView

- (id)initWithTitle:(NSString *)title andView:(UIView *)bodyView {
    if (self == [super init]) {
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.contentView];
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        self.title = title;
        
        self.bodyView = bodyView;
        
        self.titleButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bodyView.frame.size.width, 50.0f)];
        self.titleButton.userInteractionEnabled = NO;
        
        self.titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize + 2.0f];
        self.titleButton.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
        
        [self.titleButton setTitle:title forState:UIControlStateNormal];
        [self.titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self.contentView addSubview:self.titleButton];
        
        self.bodyView.frame = CGRectMake(0.0f, self.titleButton.frame.size.height, self.bodyView.frame.size.width, self.bodyView.frame.size.height);
        
        [self.contentView addSubview:self.bodyView];
        
        self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, self.bodyView.frame.origin.y + self.bodyView.frame.size.height, self.bodyView.frame.size.width, 50.0f)];
        
        [self.doneButton setTitle:@"DONE" forState:UIControlStateNormal];
        
        self.doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize];
        self.doneButton.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
        
        [self.contentView addSubview:self.doneButton];
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowRadius = 10.0f;
        self.layer.cornerRadius = 12.0f;
        self.contentView.layer.cornerRadius = 12.0f;
        self.contentView.clipsToBounds = YES;
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self.titleButton setTitle:self.title forState:UIControlStateNormal];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.contentView.frame = self.bounds;
}

@end
