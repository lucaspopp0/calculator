//
//  ViewController.m
//  Calculator Pro
//
//  Created by Lucas Popp on 9/29/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import "ViewController.h"
#import "CalculatorButton.h"
#import "CalculatorLine.h"
#import "Calculator.h"
#import "GraphingView.h"
#import "ColorSwatch.h"
#import "LinePreview.h"
#import "ConstantsTableViewController.h"
#import "SettingsTableViewController.h"

#import "CalculatorAlertView.h"
#import "ModeView.h"
#import "AppearanceView.h"

@interface ViewController ()

@property (strong, nonatomic) CalculatorButton *secondButton;
@property (strong, nonatomic) CalculatorButton *thirdButton;

@property (nonatomic) BOOL transitionedFromConstants;

@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSMutableArray *graphingButtons;

@property (strong, nonatomic) UIScrollView *mainScreen;
@property (strong, nonatomic) UIScrollView *yEqualsScreen;
@property (strong, nonatomic) UIScrollView *windowScreen;
@property (strong, nonatomic) GraphingView *graphingScreen;

@property (strong, nonatomic) UIScrollView *equationDisplayContainer;
@property (strong, nonatomic) NSMutableArray *equationDisplayLines;

@property (strong, nonatomic) UIView *buttonsContainer;
@property (strong, nonatomic) UIView *graphingButtonsContainer;

@property (nonatomic) CalculatorButtonState level;
@property (nonatomic) CalculatorButtonAppearance appearance;

@property (nonatomic) int maxColumns;
@property (nonatomic) int maxRows;

@property (strong, nonatomic) NSMutableArray *calculatorLines;
@property (strong, nonatomic) NSMutableArray *yEqualsLines;
@property (strong, nonatomic) NSMutableArray *windowLines;

@property (strong, nonatomic) Calculator *calculator;

@property (strong, nonatomic) UIView *alertShadow;
@property (strong, nonatomic) CalculatorAlertView *alertView;

@property (strong, nonatomic) ModeView *modeView;

@property (strong, nonatomic) AppearanceView *appearanceView;

@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSString *variable;

@property (strong, nonatomic) NSString *calculatorMode;

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) int cursorPosition;
@property (strong, nonatomic) CalculatorLine *lineBeforeConstants;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[self.defaults objectForKey:@"Graphing Type"] isEqual:@"Polar"]) {
        self.variable = @"θ";
    } else {
        self.variable = @"x";
    }
    
    self.constant = @"";
    
    _calculatorMode = @"Normal";
    
    self.level = CalculatorButtonStateNormal;
    
    self.calculator = [[Calculator alloc] init];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.view.frame.size.width, self.view.frame.size.width * (2.0f / 3.0f))];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:self.spinner];
    
    self.mainScreen = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.view.frame.size.width, self.view.frame.size.width * (2.0f / 3.0f))];
    [self.view addSubview:self.mainScreen];
    
    self.windowScreen = [[UIScrollView alloc] initWithFrame:self.mainScreen.frame];
    self.windowScreen.hidden = YES;
    [self.view addSubview:self.windowScreen];
    
    self.windowLines = [[NSMutableArray alloc] init];
    
    self.yEqualsScreen = [[UIScrollView alloc] initWithFrame:self.mainScreen.frame];
    self.yEqualsScreen.hidden = YES;
    
    [self.view addSubview:self.yEqualsScreen];
    
    self.graphingScreen = [[GraphingView alloc] initWithFrame:self.mainScreen.frame];
    self.graphingScreen.hidden = YES;
    
    [self.view addSubview:self.graphingScreen];
    
    self.calculatorLines = [[NSMutableArray alloc] init];
    
    self.calculatorMode = @"Normal";
    
    NSArray *history = [[NSArray alloc] initWithArray:[self.defaults objectForKey:@"History"]];
    
    for (NSDictionary *item in history) {
        [self newLine:[item[@"Is Output"] boolValue]];
        [[self currentLine].textField setText:[NSString stringWithFormat:@"%@", item[@"Value"]]];
    }
    
    [self.mainScreen addSubview:self.calculatorLines[0]];
    
    self.yEqualsLines = [[NSMutableArray alloc] init];
    self.calculatorMode = @"Y=";
    [self newLine:NO];
    
    self.calculatorMode = @"Normal";
    
    self.buttonsContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.mainScreen.frame.origin.y + self.mainScreen.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (self.mainScreen.frame.origin.y + self.mainScreen.frame.size.height))];
    [self.view addSubview:self.buttonsContainer];
    
    self.buttons = [[NSMutableArray alloc] init];
    
    self.maxColumns = 5;
    self.maxRows = 7;
    
    for (int col = 0;col < self.maxColumns;col++) {
        self.buttons[col] = [[NSMutableArray alloc] init];
        for (int row = 0;row < self.maxRows;row++) {
            CalculatorButton *button = [self buttonForColumn:col row:row];
            
            if (col == 0 && row == 0) {
                self.secondButton = button;
            } else if (col == 0 && row == 1) {
                self.thirdButton = button;
            }
            
            [self.buttons[col] addObject:button];
            
            [self.buttonsContainer addSubview:self.buttons[col][row]];
        }
    }
    
    self.level = self.level;
    
    self.graphingButtonsContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - (self.buttonsContainer.frame.size.height / (float)self.maxRows), self.view.frame.size.width, self.buttonsContainer.frame.size.height / (float)self.maxRows)];
    [self.view addSubview:self.graphingButtonsContainer];
    
    self.equationDisplayContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, self.graphingScreen.frame.origin.y + self.graphingScreen.frame.size.height, self.view.frame.size.width, self.graphingButtonsContainer.frame.origin.y - (self.graphingScreen.frame.origin.y + self.graphingScreen.frame.size.height))];
    [self.view addSubview:self.equationDisplayContainer];
    
    self.equationDisplayLines = [[NSMutableArray alloc] init];
    
    self.graphingButtons = [[NSMutableArray alloc] init];
    
    for (int i = 0;i < 4;i++) {
        CalculatorButton *button = [[CalculatorButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 4.0f) * (float)i, 0.0f, self.view.frame.size.width / 4.0f, self.graphingButtonsContainer.frame.size.height)];
        
        switch (i) {
            case 0:
                button.title = @"QUIT";
                button.identifier = @"quit";
                break;
                
            case 1:
                button.title = @"Y=";
                button.identifier = @"y=";
                break;
                
            case 2:
                button.title = @"WINDOW";
                button.identifier = @"window";
                break;
                
            case 3:
                button.title = @"POINTS OF\nINTERSECTION";
                button.identifier = @"poi";
                break;
                
            default:
                break;
        }
        
        [self.graphingButtons addObject:button];
        [self.graphingButtonsContainer addSubview:button];
        
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.view bringSubviewToFront:self.buttonsContainer];
    
    self.alertShadow = [[UIView alloc] initWithFrame:self.view.bounds];
    self.alertShadow.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    self.alertShadow.hidden = YES;
    [self.view addSubview:self.alertShadow];
    
    self.modeView = [[ModeView alloc] init];
    self.modeView.backgroundColor = [UIColor whiteColor];
    
    [self.modeView.radDegSegmentedControl addTarget:self action:@selector(saveRadiansOrDegrees) forControlEvents:UIControlEventValueChanged];
    [self.modeView.graphTypeSegmentedControl addTarget:self action:@selector(saveGraphingType) forControlEvents:UIControlEventValueChanged];
    
    self.appearanceView = [[AppearanceView alloc] init];
}

- (void)showWindow {
    for (CalculatorLine *line in self.windowLines) {
        [line removeFromSuperview];
    }
    
    [self.windowLines removeAllObjects];
    
    if ([[self.defaults objectForKey:@"Graphing Type"] isEqual: @"Function"]) {
        [self newLine:NO];
        [self lastLine].prefix = @"min x: ";
        [self lastLine].textField.text = @"-15";
        
        [self newLine:NO];
        [self lastLine].prefix = @"max x: ";
        [self lastLine].textField.text = @"15";
        
        [self newLine:NO];
        [self lastLine].prefix = @"min y: ";
        [self lastLine].textField.text = @"-10";
        
        [self newLine:NO];
        [self lastLine].prefix = @"max y: ";
        [self lastLine].textField.text = @"10";
        
        [self newLine:NO];
        [self lastLine].textField.enabled = NO;
        
        [self newLine:NO];
        [self lastLine].prefix = @"x step: ";
        [self lastLine].textField.text = @"3";
        
        [self newLine:NO];
        [self lastLine].prefix = @"y step: ";
        [self lastLine].textField.text = @"3";
    } else if ([[self.defaults objectForKey:@"Graphing Type"] isEqual: @"Polar"]) {
        [self newLine:NO];
        [self lastLine].prefix = @"min θ: ";
        [self lastLine].textField.text = @"0";
        
        [self newLine:NO];
        [self lastLine].prefix = @"max θ: ";
        [self lastLine].textField.text = @"360";
        
        [self newLine:NO];
        [self lastLine].prefix = @"min x: ";
        [self lastLine].textField.text = @"-15";
        
        [self newLine:NO];
        [self lastLine].prefix = @"max x: ";
        [self lastLine].textField.text = @"15";
        
        [self newLine:NO];
        [self lastLine].prefix = @"min y: ";
        [self lastLine].textField.text = @"-10";
        
        [self newLine:NO];
        [self lastLine].prefix = @"max y: ";
        [self lastLine].textField.text = @"10";
        
        [self newLine:NO];
        [self lastLine].textField.enabled = NO;
        
        [self newLine:NO];
        [self lastLine].prefix = @"θ step: ";
        [self lastLine].textField.text = @"7.5";
        
        [self newLine:NO];
        [self lastLine].prefix = @"x step: ";
        [self lastLine].textField.text = @"3";
        
        [self newLine:NO];
        [self lastLine].prefix = @"y step: ";
        [self lastLine].textField.text = @"3";
    }
    
    [self.windowScreen scrollRectToVisible:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) animated:NO];
}

- (void)saveRadiansOrDegrees {
    if (self.modeView.radDegSegmentedControl.selectedSegmentIndex == 0) {
        [self.defaults setObject:@"Radians" forKey:@"Radians or Degrees"];
    } else {
        [self.defaults setObject:@"Degrees" forKey:@"Radians or Degrees"];
    }
    
    [self.defaults synchronize];
    
    self.graphingScreen.equationsUpdated = YES;
    
    if ([self.calculatorMode isEqual:@"Graphing"]) {
        [self.graphingScreen refreshGraph];
    }
}

- (void)setVariable:(NSString *)variable {
    _variable = variable;
}

- (void)saveGraphingType {
    if (self.modeView.graphTypeSegmentedControl.selectedSegmentIndex == 0) {
        [self.defaults setObject:@"Function" forKey:@"Graphing Type"];
        self.variable = @"x";
    } else {
        [self.defaults setObject:@"Polar" forKey:@"Graphing Type"];
        self.variable = @"θ";
    }
    
    [self.defaults synchronize];
    
    self.graphingScreen.equationsUpdated = YES;
    
    if ([self.calculatorMode isEqual:@"Normal"]) {
        CalculatorButton *varButton = [self buttonWithIdentifier:@"var"];
        varButton.title = self.variable;
        varButton.text = self.variable;
    } else if ([self.calculatorMode isEqual:@"Graphing"]) {
        [self.graphingScreen refreshGraph];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.appearance = (CalculatorButtonAppearance)[[self.defaults objectForKey:@"Button Appearance"] integerValue];
    
    if ([self.calculatorMode isEqual:@"Normal"]) {
        [[self lastLine].textField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)appearanceAlertTriggered:(UIButton *)sender {
    [((CalculatorLine *)sender.superview).textField becomeFirstResponder];
    
    self.appearanceView.line = (CalculatorLine *)sender.superview;
    
    [self.appearanceView prepare];
    
    [self showAlertWithTitle:[NSString stringWithFormat:@"y=%@", [self currentLine].textField.text] andBody:self.appearanceView];
}

- (void)showAlertWithTitle:(NSString *)title andBody:(UIView *)body {
    if (self.alertView.superview != nil) {
        [self.alertView removeFromSuperview];
    }
    
    self.alertView = [[CalculatorAlertView alloc] initWithTitle:title andView:body];
    self.alertView.alpha = 0.0f;
    [self.view addSubview:self.alertView];
    self.alertView.frame = CGRectMake((self.view.frame.size.width - body.frame.size.width) / 2.0f, ((self.view.frame.size.height * (5.0f / 6.0f)) - (self.alertView.doneButton.frame.origin.y + self.alertView.doneButton.frame.size.height)) / 2.0f,body.frame.size.width, self.alertView.doneButton.frame.origin.y + self.alertView.doneButton.frame.size.height);
    self.alertShadow.alpha = 0.0f;
    self.alertShadow.hidden = NO;
    
    [self.alertView.doneButton addTarget:self action:@selector(closeAlert) forControlEvents:UIControlEventTouchUpInside];
    
    self.alertView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, self.view.frame.size.height - self.alertView.frame.origin.y);
    
    [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:0.8f
          initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alertView.alpha = 1.0f;
        self.alertShadow.alpha = 1.0f;
        
        self.alertView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, 0.0f);
    } completion:nil];
}

- (void)closeAlert {
    if (!self.alertShadow.hidden) {
        self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
        
        if (self.alertView.bodyView == self.appearanceView) {
            if (self.appearanceView.line.changed) {
                self.graphingScreen.equationsUpdated = YES;
            }
        }
        
        [UIView animateWithDuration:0.15f animations:^{
            self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.75f, 0.75f);
            
            self.alertShadow.alpha = 0.0f;
            self.alertView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (finished) {
                self.alertShadow.hidden = YES;
                [self.alertView removeFromSuperview];
            }
        }];
    }
}

- (void)ans:(UIButton *)sender {
    if (![sender isKindOfClass:[CalculatorButton class]]) {
        CalculatorLine *line = (CalculatorLine *)[sender superview];
        [[self currentLine].textField insertText:line.textField.text];
    } else {
        [self scrollToBottom];
        
        if ((CalculatorLine *)self.calculatorLines[0] != [self currentLine]) {
            [[self currentLine].textField insertText:((CalculatorLine *)self.calculatorLines[self.calculatorLines.count - 2]).textField.text];
        }
        
        [self setLevel:CalculatorButtonStateNormal];
    }
}

- (void)secondPressed {
    switch (self.level) {
        case CalculatorButtonStateNormal:
            self.level = CalculatorButtonStateSecond;
            break;
            
        case CalculatorButtonStateSecond:
            self.level = CalculatorButtonStateNormal;
            break;
            
        case CalculatorButtonStateThird:
            self.level = CalculatorButtonStateSecond;
            break;
            
        default:
            break;
    }
}

- (void)thirdPressed {
    switch (self.level) {
        case CalculatorButtonStateNormal:
            self.level = CalculatorButtonStateThird;
            break;
            
        case CalculatorButtonStateSecond:
            self.level = CalculatorButtonStateThird;
            break;
            
        case CalculatorButtonStateThird:
            self.level = CalculatorButtonStateNormal;
            break;
            
        default:
            break;
    }
}

- (void)setLevel:(CalculatorButtonState)level {
    _level = level;
    
    for (NSMutableArray *arr in self.buttons) {
        for (CalculatorButton *button in arr) {
            button.buttonState = self.level;
        }
    }
}

- (void)setAppearance:(CalculatorButtonAppearance)appearance {
    _appearance = appearance;
    
    for (NSMutableArray *arr in self.buttons) {
        for (CalculatorButton *button in arr) {
            button.appearance = self.appearance;
        }
    }
}

- (void)buttonPressed:(CalculatorButton *)sender {
    if ([sender.currentIdentifier isEqual:@"clear"]) {
        [self currentLine].textField.text = @"";
        [self setLevel:CalculatorButtonStateNormal];
        
        if ([self.calculatorMode isEqual:@"Y="] || [self.calculatorMode isEqual:@"Window"]) {
            self.graphingScreen.equationsUpdated = YES;
        }
    } else if ([sender.currentIdentifier isEqual:@"clear all"]) {
        if ([self.calculatorMode isEqual:@"Normal"]) {
            for (CalculatorLine *line in self.calculatorLines) {
                [line removeFromSuperview];
            }
            
            [self.calculatorLines removeAllObjects];
            [self newLine:NO];
            
            [self.mainScreen scrollRectToVisible:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) animated:NO];
        } else if ([self.calculatorMode isEqual:@"Y="]) {
            for (CalculatorLine *line in self.yEqualsLines) {
                [line removeFromSuperview];
            }
            
            [self.yEqualsLines removeAllObjects];
            [self newLine:NO];
            
            [self.yEqualsScreen scrollRectToVisible:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) animated:NO];
        }
        
        if ([self.calculatorMode isEqual:@"Y="] || [self.calculatorMode isEqual:@"Window"]) {
            self.graphingScreen.equationsUpdated = YES;
        }
        
        [self setLevel:CalculatorButtonStateNormal];
    } else if ([sender.currentIdentifier isEqual:@"2nd"]) {
        [self secondPressed];
    } else if ([sender.currentIdentifier isEqual:@"3rd"]) {
        [self thirdPressed];
    } else if ([sender.currentIdentifier isEqual:@"mode"]) {
        [self showAlertWithTitle:@"MODE" andBody:self.modeView];
    } else if ([sender.currentIdentifier isEqual:@"const"]) {
        [self setLevel:CalculatorButtonStateNormal];
        [self openConstants];
    } else if ([sender.currentIdentifier isEqual:@"quit"]) {
        if ([self.calculatorMode isEqual:@"Y="] || [self.calculatorMode isEqual:@"Graphing"] || [self.calculatorMode isEqual:@"Window"]) {
            self.calculatorMode = @"Normal";
            self.level = CalculatorButtonStateNormal;
        }
    } else if ([sender.currentIdentifier isEqual:@"del"]) {
        if ([self.calculatorMode isEqual:@"Y="]) {
            if ([[self currentLine].textField.text isEqual:@""] && self.yEqualsLines.count > 1) {
                for (int i = 0;i < self.yEqualsLines.count;i++) {
                    if (self.yEqualsLines[i] == [self currentLine] && i > 0) {
                        [self.yEqualsLines[i] removeFromSuperview];
                        [self.yEqualsLines removeObject:self.yEqualsLines[i]];
                        [((CalculatorLine *)self.yEqualsLines[i - 1]).textField becomeFirstResponder];
                        break;
                    }
                }
                
                [self adjustLineSpacing];
            } else {
                [[self currentLine].textField deletePressed];
            }
        } else {
            [[self currentLine].textField deletePressed];
        }
        
        if ([self.calculatorMode isEqual:@"Y="] || [self.calculatorMode isEqual:@"Window"]) {
            self.graphingScreen.equationsUpdated = YES;
        }
    } else if ([sender.currentIdentifier isEqual:@"poi"]) {
        if ([sender.currentTitle isEqual:@"POINTS OF\nINTERSECTION"]) {
            [self.graphingScreen searchForPointsOfIntersection];
            [self graphingButtonWithIdentifier:@"poi"].title = @"CLEAR";
        } else {
            [self.graphingScreen clearPOI];
            [self graphingButtonWithIdentifier:@"poi"].title = @"POINTS OF\nINTERSECTION";
        }
    } else if ([sender.currentIdentifier isEqual:@"y="]) {
        self.calculatorMode = @"Y=";
        self.level = CalculatorButtonStateNormal;
    } else if ([sender.currentIdentifier isEqual:@"settings"]) {
        SettingsTableViewController *settingsController = [[SettingsTableViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsController];
        [self presentViewController:navigationController animated:YES completion:nil];
        [self setLevel:CalculatorButtonStateNormal];
    } else if ([sender.currentIdentifier isEqual:@"window"]) {
        self.calculatorMode = @"Window";
        self.level = CalculatorButtonStateNormal;
    } else if ([sender.currentIdentifier isEqual:@"graph"]) {
        self.calculatorMode = @"Graphing";
        self.level = CalculatorButtonStateNormal;
    } else if ([sender.currentIdentifier isEqual:@"enter"]) {
        [self scrollToBottom];
        
        if ([self.calculatorMode isEqual:@"Normal"]) {
            if (![[self currentLine].textField.text isEqual:@""]) {
                NSString *evaluated = [self.calculator evaluateString:[self currentLine].textField.text];
                [self newLine:YES];
                [self currentLine].textField.text = evaluated;
                
                [self newLine:NO];
            }
        } else if ([self.calculatorMode isEqual:@"Y="]) {
            if (![[self currentLine].textField.text isEqual:@""]) {
                [self newLine:NO];
            }
        }
    } else if ([sender.currentIdentifier isEqual:@"ans"]) {
        [self ans:sender];
    } else {
        if ([self.calculatorMode isEqual:@"Normal"] && [[self currentLine].textField.text isEqual:@""] && ([sender.currentText isEqual:@"+"] || [sender.currentText isEqual:@"-"] || [sender.currentText isEqual:@"/"] || [sender.currentText isEqual:@"*"])) {
            [self ans:sender];
        } else if ([self.calculatorMode isEqual:@"Y="] || [self.calculatorMode isEqual:@"Window"]) {
            self.graphingScreen.equationsUpdated = YES;
        }
        
        [self scrollToBottom];
        
        [[self currentLine].textField insertText:[sender currentText]];
        
        [self setLevel:CalculatorButtonStateNormal];
    }
    
    if ([self.calculatorMode isEqual:@"Graphing"] && ([sender.currentIdentifier isEqual:@"quit"] || [sender.currentIdentifier isEqual:@"y="] || [sender.currentIdentifier isEqual:@"window"])) {
        [self.graphingScreen stopGraphing];
    }
}

- (CalculatorButton *)buttonForColumn:(int)col row:(int)row {
    CalculatorButton *button = [[CalculatorButton alloc] initWithFrame:CGRectMake((float)col * (self.buttonsContainer.frame.size.width / (float)self.maxColumns), (float)row * (self.buttonsContainer.frame.size.height / (float)self.maxRows), self.buttonsContainer.frame.size.width / (float)self.maxColumns, self.buttonsContainer.frame.size.height / (float)self.maxRows)];
    
    NSDictionary *buttonInfo = [self buttonInfoForColumn:col row:row];
    
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if (col > 0 && col < 4 && row > 2) {
        button.style = CalculatorButtonStyleLight;
    } else if (col == 4 && row > 0) {
        button.style = CalculatorButtonStyleGrey;
    }
    
    [button setTitle:buttonInfo[@"Normal"]];
    [button setSecondTitle:buttonInfo[@"Second"]];
    [button setThirdTitle:buttonInfo[@"Third"]];
    
    button.text = buttonInfo[@"Normal Text"];
    button.secondText = buttonInfo[@"Second Text"];
    button.thirdText = buttonInfo[@"Third Text"];
    
    button.identifier = buttonInfo[@"Identifier"];
    button.secondIdentifier = buttonInfo[@"Second Identifier"];
    button.thirdIdentifier = buttonInfo[@"Third Identifier"];
    
    button.normalDisabled = [buttonInfo[@"Disabled"] boolValue];
    button.secondDisabled = [buttonInfo[@"Second Disabled"] boolValue];
    button.thirdDisabled = [buttonInfo[@"Third Disabled"] boolValue];
    
    return button;
}

- (NSDictionary *)buttonInfoForColumn:(int)col row:(int)row {
    NSString *normal = @"";
    NSString *second = @"";
    NSString *third = @"";
    
    NSString *normalText = @"";
    NSString *secondText = @"";
    NSString *thirdText = @"";
    
    NSString *identifier = @"";
    NSString *secondIdentifier = @"";
    NSString *thirdIdentifier = @"";
    
    BOOL disabled = NO;
    BOOL secondDisabled = NO;
    BOOL thirdDisabled = NO;
    
    switch (col) {
        case 0:
            switch (row) {
                case 0:
                    normal = @"2ND";
                    second = @"2ND";
                    break;
                    
                case 1:
                    normal = @"3RD";
                    third = @"3RD";
                    break;
                    
                case 2:
                    identifier = @"x^2";
                    normal = @"x\u00B2";
                    normalText = @"^(2)";
                    break;
                    
                case 3:
                    identifier = @"sqrt";
                    normal = @"√";
                    normalText = @"√(";
                    second = @"abs";
                    secondText = @"abs(";
                    break;
                    
                case 4:
                    normal = @"x\u207B\u00B9";
                    normalText = @"^(-1)";
                    identifier = @"x^-1";
                    
                    second = @"10\u02E3";
                    secondText = @"10^(";
                    break;
                    
                case 5:
                    normal = @"log";
                    normalText = @"log(";
                    
                    second = @"e\u02E3";
                    secondText = @"e^(";
                    
                    third = @"e";
                    break;
                    
                case 6:
                    normal = @"ln";
                    normalText = @"ln(";
                    second = @"All";
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case 1:
            switch (row) {
                case 0:
                    normal = @"MODE";
                    second = @"QUIT";
                    secondDisabled = YES;
                    third = @"Y=";
                    break;
                    
                case 1:
                    normal = @"sin";
                    second = @"sin\u207B\u00B9";
                    normalText = @"sin(";
                    secondText = @"sin\u207B\u00B9(";
                    break;
                    
                case 2:
                    normal = @"DEL";
                    break;
                    
                case 3:
                    normal = @"7";
                    normalText = @"7";
                    break;
                    
                case 4:
                    normal = @"4";
                    normalText = @"4";
                    break;
                    
                case 5:
                    normal = @"1";
                    normalText = @"1";
                    break;
                    
                case 6:
                    normal = @"0";
                    normalText = @"0";
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case 2:
            switch (row) {
                case 0:
                    identifier = @"var";
                    normal = self.variable;
                    normalText = self.variable;
                    third = @"WINDOW";
                    break;
                    
                case 1:
                    normal = @"cos";
                    normalText = @"cos(";
                    second = @"cos\u207B\u00B9";
                    secondText= @"cos\u207B\u00B9(";
                    break;
                    
                case 2:
                    normal = @"(";
                    normalText = @"(";
                    break;
                    
                case 3:
                    normal = @"8";
                    normalText = @"8";
                    break;
                    
                case 4:
                    normal = @"5";
                    normalText = @"5";
                    break;
                    
                case 5:
                    normal = @"2";
                    normalText = @"2";
                    break;
                    
                case 6:
                    normal = @".";
                    normalText = @".";
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case 3:
            switch (row) {
                case 0:
                    normal = @"CONST";
                    third = @"GRAPH";
                    break;
                    
                case 1:
                    normal = @"tan";
                    normalText = @"tan(";
                    second = @"tan\u207B\u00B9";
                    secondText = @"tan\u207B\u00B9(";
                    break;
                    
                case 2:
                    normal = @")";
                    normalText = @")";
                    break;
                    
                case 3:
                    normal = @"9";
                    normalText = @"9";
                    break;
                    
                case 4:
                    normal = @"6";
                    normalText = @"6";
                    break;
                    
                case 5:
                    normal = @"3";
                    normalText = @"3";
                    break;
                    
                case 6:
                    normal = @"(-)";
                    normalText = @"-";
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case 4:
            switch (row) {
                case 0:
                    normal = @"CLEAR";
                    second = @"CLEAR\nALL";
                    secondIdentifier = @"clear all";
                    third = @"SETTINGS";
                    break;
                    
                case 1:
                    normal = @"^";
                    normalText = @"^(";
                    
                    second = @"π";
                    secondText = @"π";
                    secondIdentifier = @"pi";
                    break;
                    
                case 2:
                    normal = @"÷";
                    identifier = @"/";
                    normalText = @"/";
                    break;
                    
                case 3:
                    identifier = @"*";
                    normal = @"×";
                    normalText = @"*";
                    break;
                    
                case 4:
                    normal = @"−";
                    normalText = @"-";
                    break;
                    
                case 5:
                    normal = @"+";
                    normalText = @"+";
                    break;
                    
                case 6:
                    normal = @"ENTER";
                    second = @"ANS";
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
    
    if ([identifier isEqual:@""]) {
        identifier = [normal lowercaseString];
    }
    
    if ([secondIdentifier isEqual:@""]) {
        secondIdentifier = [second lowercaseString];
    }
    
    if ([thirdIdentifier isEqual:@""]) {
        thirdIdentifier = [third lowercaseString];
    }
    
    return [[NSDictionary alloc] initWithObjects:@[normal, second, third, normalText, secondText, thirdText, identifier, secondIdentifier, thirdIdentifier, @(disabled), @(secondDisabled), @(thirdDisabled)] forKeys:@[@"Normal", @"Second", @"Third", @"Normal Text", @"Second Text", @"Third Text", @"Identifier", @"Second Identifier", @"Third Identifier", @"Disabled", @"Second Disabled", @"Third Disabled"]];
}

- (void)adjustLineSpacing {
    if ([self.calculatorMode isEqual:@"Normal"]) {
        CalculatorLine *line;
        CalculatorLine *previousLine;
        
        for (int i = 0;i < self.calculatorLines.count;i++) {
            line = (CalculatorLine *)self.calculatorLines[i];
            
            if (i == 0) {
                line.frame = CGRectMake(0.0f, 0.0f, self.mainScreen.frame.size.width, line.frame.size.height);
            } else {
                previousLine = (CalculatorLine *)self.calculatorLines[i - 1];
                line.frame = CGRectMake(0.0f, previousLine.frame.origin.y + previousLine.frame.size.height, previousLine.frame.size.width, line.frame.size.height);
            }
        }
        
        self.mainScreen.contentSize = CGSizeMake(self.mainScreen.frame.size.width, line.frame.origin.y + line.frame.size.height);
    } else if ([self.calculatorMode isEqual:@"Y="]) {
        CalculatorLine *line;
        CalculatorLine *previousLine;
        
        for (int i = 0;i < self.yEqualsLines.count;i++) {
            line = (CalculatorLine *)self.yEqualsLines[i];
            
            if (i == 0) {
                line.frame = CGRectMake(0.0f, 0.0f, self.yEqualsScreen.frame.size.width, line.frame.size.height);
            } else {
                previousLine = (CalculatorLine *)self.yEqualsLines[i - 1];
                line.frame = CGRectMake(0.0f, previousLine.frame.origin.y + previousLine.frame.size.height, previousLine.frame.size.width, line.frame.size.height);
            }
        }
        
        self.yEqualsScreen.contentSize = CGSizeMake(self.yEqualsScreen.frame.size.width, line.frame.origin.y + line.frame.size.height);
    } else if ([self.calculatorMode isEqual:@"Graphing"]) {
        CalculatorLine *line;
        CalculatorLine *previousLine;
        
        for (int i = 0;i < self.equationDisplayLines.count;i++) {
            line = (CalculatorLine *)self.equationDisplayLines[i];
            
            if (i == 0) {
                line.frame = CGRectMake(0.0f, 0.0f, self.equationDisplayContainer.frame.size.width, line.frame.size.height);
            } else {
                previousLine = (CalculatorLine *)self.equationDisplayLines[i - 1];
                line.frame = CGRectMake(0.0f, previousLine.frame.origin.y + previousLine.frame.size.height, previousLine.frame.size.width, line.frame.size.height);
            }
        }
        
        self.equationDisplayContainer.contentSize = CGSizeMake(self.equationDisplayContainer.frame.size.width, line.frame.origin.y + line.frame.size.height);
    } else if ([self.calculatorMode isEqual:@"Window"]) {
        CalculatorLine *line;
        CalculatorLine *previousLine;
        
        for (int i = 0;i < self.windowLines.count;i++) {
            line = (CalculatorLine *)self.windowLines[i];
            
            if (i == 0) {
                line.frame = CGRectMake(0.0f, 0.0f, self.windowScreen.frame.size.width, line.frame.size.height);
            } else {
                previousLine = (CalculatorLine *)self.windowLines[i - 1];
                line.frame = CGRectMake(0.0f, previousLine.frame.origin.y + previousLine.frame.size.height, previousLine.frame.size.width, line.frame.size.height);
            }
        }
        
        self.windowScreen.contentSize = CGSizeMake(self.windowScreen.frame.size.width, line.frame.origin.y + line.frame.size.height);
    }
}

- (void)newLine:(BOOL)isOutput {
    CGRect newFrame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 28.0f);
    
    if ([self.calculatorMode isEqual:@"Normal"]) {
        if (self.calculatorLines.count > 0) {
            newFrame = [self lastLine].frame;
            [self lastLine].textField.enabled = NO;
            [self lastLine].isTappable = YES;
            
            newFrame.origin.y = newFrame.origin.y + newFrame.size.height;
        }
    } else if ([self.calculatorMode isEqual:@"Y="]) {
        if (self.yEqualsLines.count > 0) {
            newFrame = [self currentLine].frame;
            
            newFrame.origin.y = newFrame.origin.y + newFrame.size.height;
        }
    } else if ([self.calculatorMode isEqual:@"Graphing"]) {
        if (self.equationDisplayLines.count > 0) {
            newFrame = [self currentLine].frame;
            
            newFrame.origin.y = newFrame.origin.y + newFrame.size.height;
        }
    } else if ([self.calculatorMode isEqual:@"Window"]) {
        if (self.windowLines.count > 0) {
            newFrame = [self lastLine].frame;
            
            newFrame.origin.y = newFrame.origin.y + newFrame.size.height;
        }
    }
    
    CalculatorLine *nextLine = [[CalculatorLine alloc] initWithFrame:newFrame];
    
    if ([self.calculatorMode isEqual:@"Normal"]) {
        [self.calculatorLines addObject:nextLine];
        [self.mainScreen addSubview:nextLine];
        nextLine.isOutput = isOutput;
        
        [nextLine.reciever addTarget:self action:@selector(ans:) forControlEvents:UIControlEventTouchUpInside];
        
        self.mainScreen.contentSize = CGSizeMake(self.view.frame.size.width, nextLine.frame.origin.y + nextLine.frame.size.height);
        [self scrollToBottom];
    } else if ([self.calculatorMode isEqual:@"Y="]) {
        [self.yEqualsLines addObject:nextLine];
        [self.yEqualsScreen addSubview:nextLine];
        
        nextLine.prefix = @"y=";
        nextLine.showsAppearanceEditor = YES;
        [nextLine.appearanceButton addTarget:self action:@selector(appearanceAlertTriggered:) forControlEvents:UIControlEventTouchUpInside];
        
        self.yEqualsScreen.contentSize = CGSizeMake(self.view.frame.size.width, nextLine.frame.origin.y + nextLine.frame.size.height);
        [self scrollToBottom];
    } else if ([self.calculatorMode isEqual:@"Graphing"]) {
        [self.equationDisplayLines addObject:nextLine];
        [self.equationDisplayContainer addSubview:nextLine];
        
        nextLine.showsAppearanceEditor = YES;
        
        self.equationDisplayContainer.contentSize = CGSizeMake(self.view.frame.size.width, nextLine.frame.origin.y + nextLine.frame.size.height);
    } else if ([self.calculatorMode isEqual:@"Window"]) {
        [self.windowLines addObject:nextLine];
        [self.windowScreen addSubview:nextLine];
        
        self.windowScreen.contentSize = CGSizeMake(self.view.frame.size.width, nextLine.frame.origin.y + nextLine.frame.size.height);
        [self scrollToBottom];
    }
    
    nextLine.isTappable = NO;
    
    [self adjustLineSpacing];
}

- (CalculatorLine *)lastLine {
    if ([self.calculatorMode isEqual:@"Normal"]) {
        return (CalculatorLine *)[self.calculatorLines lastObject];
    } else if ([self.calculatorMode isEqual:@"Y="]) {
        return (CalculatorLine *)[self.yEqualsLines lastObject];
    } else if ([self.calculatorMode isEqual:@"Graphing"]) {
        return (CalculatorLine *)[self.equationDisplayLines lastObject];
    } else if ([self.calculatorMode isEqual:@"Window"]) {
        return (CalculatorLine *)[self.windowLines lastObject];
    }
    
    return (CalculatorLine *)[self.calculatorLines lastObject];
}

- (CalculatorLine *)currentLine {
    if ([self.calculatorMode isEqual:@"Normal"]) {
        for (CalculatorLine *line in self.calculatorLines) {
            if (line.textField.isFirstResponder) {
                return line;
            }
        }
    } else if ([self.calculatorMode isEqual:@"Y="]) {
        for (CalculatorLine *line in self.yEqualsLines) {
            if (line.textField.isFirstResponder) {
                return line;
            }
        }
    } else if ([self.calculatorMode isEqual:@"Window"]) {
        for (CalculatorLine *line in self.windowLines) {
            if (line.textField.isFirstResponder) {
                return line;
            }
        }
    }
    
    return (CalculatorLine *)[self.calculatorLines lastObject];
}

- (void)scrollToBottom {
    if ([self.calculatorMode isEqual:@"Normal"]) {
        [self.mainScreen scrollRectToVisible:[self lastLine].frame animated:NO];
    } else if ([self.calculatorMode isEqual:@"Y="]) {
        [self.yEqualsScreen scrollRectToVisible:[self lastLine].frame animated:NO];
    } else if ([self.calculatorMode isEqual:@"Window"]) {
        [self.windowScreen scrollRectToVisible:[self lastLine].frame animated:NO];
    }
    
    [self adjustLineSpacing];
}

- (void)setCalculatorMode:(NSString *)calculatorMode {
    _calculatorMode = calculatorMode;
    
    self.mainScreen.hidden = YES;
    self.yEqualsScreen.hidden = YES;
    self.windowScreen.hidden = YES;
    self.graphingScreen.hidden = YES;
    
    [self buttonWithIdentifier:@"quit"].secondDisabled = NO;
    [self buttonWithIdentifier:@"ans"].secondDisabled = NO;
    [self buttonWithIdentifier:@"y="].thirdDisabled = NO;
    [self buttonWithIdentifier:@"window"].thirdDisabled = NO;
    [self buttonWithIdentifier:@"graph"].thirdDisabled = NO;
    
    [self buttonWithIdentifier:@"clear all"].secondDisabled = YES;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.buttonsContainer.frame = CGRectMake(0.0f, self.view.frame.size.height - self.buttonsContainer.frame.size.height, self.view.frame.size.width, self.buttonsContainer.frame.size.height);
    }];
    
    if (![self.calculatorMode isEqual:@"Graphing"]) {
        [self.graphingScreen clearPOI];
        [self graphingButtonWithIdentifier:@"poi"].title = @"POINTS OF\nINTERSECTION";
    }
    
    if ([self.calculatorMode isEqual:@"Normal"]) {
        self.mainScreen.hidden = NO;
        [[self lastLine].textField becomeFirstResponder];
        
        [self buttonWithIdentifier:@"quit"].secondDisabled = YES;
        [self buttonWithIdentifier:@"clear all"].secondDisabled = NO;
    } else if ([self.calculatorMode isEqual:@"Y="]) {
        self.yEqualsScreen.hidden = NO;
        [[self lastLine].textField becomeFirstResponder];
        
        [self buttonWithIdentifier:@"ans"].secondDisabled = YES;
        [self buttonWithIdentifier:@"y="].thirdDisabled = YES;
        [self buttonWithIdentifier:@"clear all"].secondDisabled = NO;
    } else if ([self.calculatorMode isEqual:@"Window"]) {
        [self showWindow];
        
        self.windowScreen.hidden = NO;
        [((CalculatorLine *)self.windowLines[0]).textField becomeFirstResponder];
        
        [self buttonWithIdentifier:@"ans"].secondDisabled = YES;
        [self buttonWithIdentifier:@"window"].thirdDisabled = YES;
        
        [self buttonWithIdentifier:@"clear all"].secondDisabled = YES;
    } else if ([self.calculatorMode isEqual:@"Graphing"]) {
        if (self.graphingScreen.equationsUpdated) {
            for (CalculatorLine *line in self.windowLines) {
                line.textField.text = [self.calculator efficientlyGetValuesForExpression:line.textField.text][@"String"];
            }
            
            for (CalculatorLine *line in self.windowLines) {
                if ([line.prefix containsString:@"x min:"]) {
                    self.graphingScreen.xMin = [self.calculator getDoubleValueOfExpression:line.textField.text];
                } else if ([line.prefix containsString:@"x max:"]) {
                    self.graphingScreen.xMax = [self.calculator getDoubleValueOfExpression:line.textField.text];
                } else if ([line.prefix containsString:@"y min:"]) {
                    self.graphingScreen.yMin = [self.calculator getDoubleValueOfExpression:line.textField.text];
                } else if ([line.prefix containsString:@"y max:"]) {
                    self.graphingScreen.yMax = [self.calculator getDoubleValueOfExpression:line.textField.text];
                } else if ([line.prefix containsString:@"θ min:"]) {
                    self.graphingScreen.tMin = [self.calculator getDoubleValueOfExpression:line.textField.text];
                } else if ([line.prefix containsString:@"θ max:"]) {
                    self.graphingScreen.tMax = [self.calculator getDoubleValueOfExpression:line.textField.text];
                } else if ([line.prefix containsString:@"x step:"]) {
                    self.graphingScreen.xStep = [self.calculator getDoubleValueOfExpression:line.textField.text];
                } else if ([line.prefix containsString:@"y step:"]) {
                    self.graphingScreen.yStep = [self.calculator getDoubleValueOfExpression:line.textField.text];
                } else if ([line.prefix containsString:@"θ step:"]) {
                    self.graphingScreen.tStep = [self.calculator getDoubleValueOfExpression:line.textField.text];
                }
            }
            
            [self performSelectorOnMainThread:@selector(updateGraphingLines) withObject:nil waitUntilDone:YES];
        } else {
            self.graphingScreen.hidden = NO;
        }
        
        [self buttonWithIdentifier:@"ans"].secondDisabled = YES;
        [self buttonWithIdentifier:@"graph"].thirdDisabled = YES;
        
        [self buttonWithIdentifier:@"clear all"].secondDisabled = YES;
        
        [UIView animateWithDuration:0.2f animations:^{
            self.buttonsContainer.frame = CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, self.buttonsContainer.frame.size.height);
        }];
    }
}

- (void)updateGraphingLines {
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    for (CalculatorLine *line in self.yEqualsLines) {
        [lines addObject:@{
                           @"Equation" : [self.calculator formatStringForEfficiency:line.textField.text],
                           @"Formatted Equation" : line.textField.text,
                           @"Color" : line.lineColor,
                           @"Thickness" : @(line.lineThickness),
                           @"Dashed" : @(line.lineDashed)
                           }];
    }
    
    self.graphingScreen.lines = [[NSArray alloc] initWithArray:lines];
    
    self.graphingScreen.hidden = NO;
    
    [self.graphingScreen refreshGraph];
}

- (CalculatorButton *)buttonWithIdentifier:(NSString *)identifier {
    for (NSMutableArray *arr in self.buttons) {
        for (CalculatorButton *button in arr) {
            if ([button.identifier isEqual:identifier] || [button.secondIdentifier isEqual:identifier] || [button.thirdIdentifier isEqual:identifier]) {
                return button;
            }
        }
    }
    
    NSLog(@"ERROR: Button with identifier %@ not found", identifier);
    
    return [[CalculatorButton alloc] init];
}

- (CalculatorButton *)graphingButtonWithIdentifier:(NSString *)identifier {
    for (CalculatorButton *button in self.graphingButtons) {
        if ([button.identifier isEqual:identifier] || [button.secondIdentifier isEqual:identifier] || [button.thirdIdentifier isEqual:identifier]) {
            return button;
        }
    }
    
    NSLog(@"ERROR: Button with identifier %@ not found", identifier);
    
    return [[CalculatorButton alloc] init];
}

- (void)openConstants {
    ConstantsTableViewController *table = [[ConstantsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:table];
    
    self.lineBeforeConstants = [self currentLine];
    self.cursorPosition = [[self currentLine].textField cursorPosition];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    self.transitionedFromConstants = YES;
}

- (void)handleConstant:(NSString *)constant {
    [[self lastLine].textField becomeFirstResponder];
    [[self currentLine].textField insertText:constant];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.transitionedFromConstants) {
        [self.lineBeforeConstants.textField becomeFirstResponder];
        [[self currentLine].textField setCursorIndex:self.cursorPosition];
        [[self currentLine].textField insertText:self.constant];
        self.constant = @"";
        
        if ([self.calculatorMode isEqual:@"Y="] || [self.calculatorMode isEqual:@"Window"]) {
            self.graphingScreen.equationsUpdated = YES;
        }
    }
    
    self.transitionedFromConstants = NO;
}

- (void)analyzeGraphTouchAt:(float)x {
    for (CalculatorLine *line in self.equationDisplayLines) {
        [line removeFromSuperview];
    }
    
    [self.equationDisplayLines removeAllObjects];
    
    [self newLine:NO];
    [self lastLine].showsAppearanceEditor = NO;
    [self lastLine].prefix = @"x=";
    [self lastLine].textField.text = [NSString stringWithFormat:@"%f", x];
    [self lastLine].textField.enabled = NO;
    
    for (NSDictionary *line in self.graphingScreen.lines) {
        [self newLine:NO];
        [self lastLine].prefix = [NSString stringWithFormat:@"%@=", line[@"Formatted Equation"]];
        
        NSString *value = [self.calculator efficientlyEvaluateString:line[@"Equation"] withVariable:@"x" value:x];
        
        if ([value isEqual:@"nan"]) {
            [self lastLine].textField.text = @"undefined";
        } else {
            [self lastLine].textField.text = value;
        }
        
        [self lastLine].lineColor = line[@"Color"];
        [self lastLine].lineDashed = [line[@"Dashed"] boolValue];
        [self lastLine].lineThickness = [line[@"Thickness"] floatValue];
        [self lastLine].textField.enabled = NO;
    }
}

@end
