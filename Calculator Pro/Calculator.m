//
//  Calculator.m
//  Calculator Pro
//
//  Created by Lucas Popp on 10/16/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import "Calculator.h"
#import <UIKit/UIKit.h>

@interface Calculator ()

@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation Calculator

- (id)init {
    if (self == [super init]) {
        self.defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (NSDictionary *)efficientlyGetValuesForExpression:(NSString *)input {
    NSString *format = input;
    
    NSString *stringValue = @"";
    double doubleValue = NAN;
    
    @try {
        NSExpression *expression = [NSExpression expressionWithFormat:format];
        stringValue = [NSString stringWithFormat:@"%@", [expression expressionValueWithObject:nil context:nil]];
        
        if ([stringValue rangeOfString:@"e"].location != NSNotFound) {
            stringValue = [self replaceWeirdE:[NSString stringWithFormat:@"%@", [expression expressionValueWithObject:nil context:nil]] isFinal:NO];
            
            NSExpression *expression2 = [NSExpression expressionWithFormat:stringValue];
            doubleValue = [self evaluateWeirdE:[NSString stringWithFormat:@"%@", [expression2 expressionValueWithObject:nil context:nil]]];
            stringValue = [self replaceWeirdE:[NSString stringWithFormat:@"%@", [expression2 expressionValueWithObject:nil context:nil]] isFinal:YES];
        }
        
        if ([stringValue isEqual:@"inf"]) {
            stringValue = @"ERR: Cannot divide by zero";
            doubleValue = NAN;
        }
    } @catch (NSException *exception) {
        stringValue = @"ERR";
        doubleValue = NAN;
    } @finally {
        return @{
                 @"String" : stringValue,
                 @"Double" : @(doubleValue)
                 };
    }
    
    return @{
             @"String" : stringValue,
             @"Double" : @(doubleValue)
             };
}

- (NSDictionary *)efficientlyGetValuesForExpression:(NSString *)input withVariable:(NSString *)variable value:(double)value {
    NSString *format = [self replaceVariable:variable withValue:value inString:input];
    
    NSString *stringValue = @"";
    double doubleValue = NAN;
    
    @try {
        NSExpression *expression = [NSExpression expressionWithFormat:format];
        stringValue = [NSString stringWithFormat:@"%@", [expression expressionValueWithObject:nil context:nil]];
        
        if ([stringValue rangeOfString:@"e"].location != NSNotFound) {
            stringValue = [self replaceWeirdE:[NSString stringWithFormat:@"%@", [expression expressionValueWithObject:nil context:nil]] isFinal:NO];
            
            NSExpression *expression2 = [NSExpression expressionWithFormat:stringValue];
            doubleValue = [self evaluateWeirdE:[NSString stringWithFormat:@"%@", [expression2 expressionValueWithObject:nil context:nil]]];
            stringValue = [self replaceWeirdE:[NSString stringWithFormat:@"%@", [expression2 expressionValueWithObject:nil context:nil]] isFinal:YES];
        }
        
        if ([stringValue isEqual:@"inf"]) {
            stringValue = @"ERR: Cannot divide by zero";
            doubleValue = NAN;
        }
    } @catch (NSException *exception) {
        stringValue = @"ERR";
        doubleValue = NAN;
    } @finally {
        return @{
                 @"String" : stringValue,
                 @"Double" : @(doubleValue)
                 };
    }
    
    return @{
             @"String" : stringValue,
             @"Double" : @(doubleValue)
             };
}

- (NSString *)formatStringForEfficiency:(NSString *)input {
    NSString *output = [self formatString:input];
    
    if (![self stringHasBalancedParenthesis:output]) {
        return @"ERR: Unbalanced parenthesis";
    }
    
    output = [self addImpliedMultiplicationSymbols:output];
    output = [self handleTrigFunctions:output];
    
    output = [output stringByReplacingOccurrencesOfString:@"√" withString:@"sqrt"];
    output = [output stringByReplacingOccurrencesOfString:@"+" withString:@" + "];
    output = [output stringByReplacingOccurrencesOfString:@"−" withString:@" - "];
    output = [output stringByReplacingOccurrencesOfString:@"/" withString:@" / "];
    output = [output stringByReplacingOccurrencesOfString:@"*" withString:@" * "];
    output = [output stringByReplacingOccurrencesOfString:@"^" withString:@" ** "];
    
    output = [output stringByReplacingOccurrencesOfString:@"π" withString:[NSString stringWithFormat:@"%1.16f", M_PI]];
    output = [output stringByReplacingOccurrencesOfString:@"e" withString:[NSString stringWithFormat:@"%1.16f", M_E]];
    
    return output;
}

- (NSString *)replaceVariable:(NSString *)variableName withValue:(double)value inString:(NSString *)formula {
    return [formula stringByReplacingOccurrencesOfString:variableName withString:[NSString stringWithFormat:@"(%f)", value]];
}

- (double)getDoubleValueOfExpression:(NSString *)input {
    NSString *format = [self formatStringForEfficiency:input];
    
    return [self getDoubleValueEfficientlyOfExpression:format];
}

- (double)getDoubleValueOfExpression:(NSString *)input withVariable:(NSString *)variable value:(double)value {
    NSString *format = [self formatStringForEfficiency:input];
    
    return [self getDoubleValueEfficientlyOfExpression:format withVariable:variable value:value];
}

- (double)getDoubleValueEfficientlyOfExpression:(NSString *)input {
    double toReturn;
    
    @try {
        NSExpression *expression = [NSExpression expressionWithFormat:input];
        NSString *stringToReturn = [NSString stringWithFormat:@"%@", [expression expressionValueWithObject:nil context:nil]];
        
        if ([stringToReturn rangeOfString:@"e"].location != NSNotFound) {
            stringToReturn = [self replaceWeirdE:[NSString stringWithFormat:@"%@", [expression expressionValueWithObject:nil context:nil]] isFinal:NO];
            
            NSExpression *expression2 = [NSExpression expressionWithFormat:stringToReturn];
            toReturn = [self evaluateWeirdE:[NSString stringWithFormat:@"%@", [expression2 expressionValueWithObject:nil context:nil]]];
        } else {
            if ([stringToReturn isEqual:@"nan"]) {
                toReturn = NAN;
            } else {
                toReturn = [stringToReturn doubleValue];
            }
        }
    } @catch (NSException *exception) {
        toReturn = NAN;
    } @finally {
        return toReturn;
    }
}

- (double)getDoubleValueEfficientlyOfExpression:(NSString *)input withVariable:(NSString *)variable value:(double)value {
    NSString *format = [self replaceVariable:variable withValue:value inString:input];
    
    return [self getDoubleValueEfficientlyOfExpression:format];
}

- (NSString *)evaluateString:(NSString *)input {
    NSString *format = [self formatStringForEfficiency:input];
    
    if (![self stringHasBalancedParenthesis:format]) {
        return @"ERR: Unbalanced parenthesis";
    }
    
    return [self efficientlyEvaluateString:format];
}

- (NSString *)evaluateString:(NSString *)input withVariable:(NSString *)variable value:(double)value {
    NSString *format = [self formatStringForEfficiency:input];
    
    if (![self stringHasBalancedParenthesis:format]) {
        return @"ERR: Unbalanced parenthesis";
    }
    
    return [self efficientlyEvaluateString:format withVariable:variable value:value];
}

- (NSString *)efficientlyEvaluateString:(NSString *)input {
    NSString *toReturn;
    
    @try {
        NSExpression *expression = [NSExpression expressionWithFormat:input];
        toReturn = [NSString stringWithFormat:@"%@", [expression expressionValueWithObject:nil context:nil]];
        
        if ([toReturn rangeOfString:@"e"].location != NSNotFound) {
            toReturn = [self replaceWeirdE:[NSString stringWithFormat:@"%@", [expression expressionValueWithObject:nil context:nil]] isFinal:NO];
            
            toReturn = [self replaceWeirdE:[NSString stringWithFormat:@"%@", [[NSExpression expressionWithFormat:toReturn] expressionValueWithObject:nil context:nil]] isFinal:YES];
        }
        
        if ([toReturn isEqual:@"inf"]) {
            toReturn = @"ERR: Cannot divide by zero";
        }
    } @catch (NSException *exception) {
        toReturn = @"ERR";
    } @finally {
        return toReturn;
    }
}

- (NSString *)efficientlyEvaluateString:(NSString *)input withVariable:(NSString *)variable value:(double)value {
    NSString *format = [self replaceVariable:variable withValue:value inString:input];
    
    return [self efficientlyEvaluateString:format];
}

- (BOOL)stringHasBalancedParenthesis:(NSString *)formula {
    int parenthesisLevel = 0;
    
    for (int i = 0;i < formula.length;i++) {
        if ([formula characterAtIndex:i] == '(') {
            parenthesisLevel++;
        } else if ([formula characterAtIndex:i] == ')') {
            parenthesisLevel--;
        }
    }
    
    return (parenthesisLevel == 0);
}

- (NSString *)replaceWeirdE:(NSString *)formula isFinal:(BOOL)isFinal {
    NSRange range = [formula rangeOfString:@"e"];
    
    if (isFinal) {
        return [NSString stringWithFormat:@"%@ * 10^(%@)", [formula substringToIndex:range.location], [formula substringFromIndex:range.location + 1]];
    } else {
        return [NSString stringWithFormat:@"%@ * 10 ** (%i)", [formula substringToIndex:range.location], [[formula substringFromIndex:range.location + 1] intValue]];
    }
}

- (double)evaluateWeirdE:(NSString *)formula {
    NSRange range = [formula rangeOfString:@"e"];
    
    return [[formula substringToIndex:range.location] doubleValue] * pow(10, [[formula substringFromIndex:range.location + 1] doubleValue]);
}

- (NSString *)handleTrigFunctions:(NSString *)formula {
    NSString *newString = formula;
    
    while ([newString rangeOfString:@"sin⁻¹("].location != NSNotFound) {
        int startLocation = (int)[newString rangeOfString:@"sin⁻¹("].location + (int)[newString rangeOfString:@"sin⁻¹("].length - 1;
        
        int parenthesisLevel = 0;
        
        for (int i = startLocation;i < newString.length;i++) {
            if ([newString characterAtIndex:i] == '(') {
                parenthesisLevel++;
            } else if ([newString characterAtIndex:i] == ')') {
                parenthesisLevel--;
            }
            
            if (parenthesisLevel == 0) {
                if ([[self.defaults objectForKey:@"Radians or Degrees"] isEqual:@"Radians"]) {
                    newString = [NSString stringWithFormat:@"%@, 'asin'%@", [newString substringToIndex:i], [newString substringFromIndex:i]];
                } else {
                    newString = [NSString stringWithFormat:@"%@, 'dasin'%@", [newString substringToIndex:i], [newString substringFromIndex:i]];
                }
                
                newString = [NSString stringWithFormat:@"%@FUNCTION%@", [newString substringToIndex:startLocation - 5], [newString substringFromIndex:startLocation]];
                break;
            }
        }
    }
    
    while ([newString rangeOfString:@"cos⁻¹("].location != NSNotFound) {
        int startLocation = (int)[newString rangeOfString:@"cos⁻¹("].location + (int)[newString rangeOfString:@"cos⁻¹("].length - 1;
        
        int parenthesisLevel = 0;
        
        for (int i = startLocation;i < newString.length;i++) {
            if ([newString characterAtIndex:i] == '(') {
                parenthesisLevel++;
            } else if ([newString characterAtIndex:i] == ')') {
                parenthesisLevel--;
            }
            
            if (parenthesisLevel == 0) {
                if ([[self.defaults objectForKey:@"Radians or Degrees"] isEqual:@"Radians"]) {
                    newString = [NSString stringWithFormat:@"%@, 'acos'%@", [newString substringToIndex:i], [newString substringFromIndex:i]];
                } else {
                    newString = [NSString stringWithFormat:@"%@, 'dacos'%@", [newString substringToIndex:i], [newString substringFromIndex:i]];
                }
                
                newString = [NSString stringWithFormat:@"%@FUNCTION%@", [newString substringToIndex:startLocation - 5], [newString substringFromIndex:startLocation]];
                break;
            }
        }
    }
    
    while ([newString rangeOfString:@"tan⁻¹("].location != NSNotFound) {
        int startLocation = (int)[newString rangeOfString:@"tan⁻¹("].location + (int)[newString rangeOfString:@"tan⁻¹("].length - 1;
        
        int parenthesisLevel = 0;
        
        for (int i = startLocation;i < newString.length;i++) {
            if ([newString characterAtIndex:i] == '(') {
                parenthesisLevel++;
            } else if ([newString characterAtIndex:i] == ')') {
                parenthesisLevel--;
            }
            
            if (parenthesisLevel == 0) {
                if ([[self.defaults objectForKey:@"Radians or Degrees"] isEqual:@"Radians"]) {
                    newString = [NSString stringWithFormat:@"%@, 'atan'%@", [newString substringToIndex:i], [newString substringFromIndex:i]];
                } else {
                    newString = [NSString stringWithFormat:@"%@, 'datan'%@", [newString substringToIndex:i], [newString substringFromIndex:i]];
                }
                
                newString = [NSString stringWithFormat:@"%@FUNCTION%@", [newString substringToIndex:startLocation - 5], [newString substringFromIndex:startLocation]];
                break;
            }
        }
    }
    
    while ([newString rangeOfString:@"sin("].location != NSNotFound) {
        int startLocation = (int)[newString rangeOfString:@"sin("].location + (int)[newString rangeOfString:@"sin("].length - 1;
        
        int parenthesisLevel = 0;
        
        for (int i = startLocation;i < newString.length;i++) {
            if ([newString characterAtIndex:i] == '(') {
                parenthesisLevel++;
            } else if ([newString characterAtIndex:i] == ')') {
                parenthesisLevel--;
            }
            
            if (parenthesisLevel == 0) {
                if ([[self.defaults objectForKey:@"Radians or Degrees"] isEqual:@"Radians"]) {
                    newString = [NSString stringWithFormat:@"%@, 'sin'%@", [newString substringToIndex:i], [newString substringFromIndex:i]];
                } else {
                    newString = [NSString stringWithFormat:@"%@, 'dsin'%@", [newString substringToIndex:i], [newString substringFromIndex:i]];
                }
                
                newString = [NSString stringWithFormat:@"%@FUNCTION%@", [newString substringToIndex:startLocation - 3], [newString substringFromIndex:startLocation]];
                break;
            }
        }
    }
    
    while ([newString rangeOfString:@"cos("].location != NSNotFound) {
        int startLocation = (int)[newString rangeOfString:@"cos("].location + (int)[newString rangeOfString:@"cos("].length - 1;
        
        int parenthesisLevel = 0;
        
        for (int i = startLocation;i < newString.length;i++) {
            if ([newString characterAtIndex:i] == '(') {
                parenthesisLevel++;
            } else if ([newString characterAtIndex:i] == ')') {
                parenthesisLevel--;
            }
            
            if (parenthesisLevel == 0) {
                if ([[self.defaults objectForKey:@"Radians or Degrees"] isEqual:@"Radians"]) {
                    newString = [NSString stringWithFormat:@"%@, 'cos'%@", [newString substringToIndex:i], [newString substringFromIndex:i]];
                } else {
                    newString = [NSString stringWithFormat:@"%@, 'dcos'%@", [newString substringToIndex:i], [newString substringFromIndex:i]];
                }
                
                newString = [NSString stringWithFormat:@"%@FUNCTION%@", [newString substringToIndex:startLocation - 3], [newString substringFromIndex:startLocation]];
                break;
            }
        }
    }
    
    while ([newString rangeOfString:@"tan("].location != NSNotFound) {
        int startLocation = (int)[newString rangeOfString:@"tan("].location + (int)[newString rangeOfString:@"tan("].length - 1;
        
        int parenthesisLevel = 0;
        
        for (int i = startLocation;i < newString.length;i++) {
            if ([newString characterAtIndex:i] == '(') {
                parenthesisLevel++;
            } else if ([newString characterAtIndex:i] == ')') {
                parenthesisLevel--;
            }
            
            if (parenthesisLevel == 0) {
                if ([[self.defaults objectForKey:@"Radians or Degrees"] isEqual:@"Radians"]) {
                    newString = [NSString stringWithFormat:@"%@, 'tan'%@", [newString substringToIndex:i], [newString substringFromIndex:i]];
                } else {
                    newString = [NSString stringWithFormat:@"%@, 'dtan'%@", [newString substringToIndex:i], [newString substringFromIndex:i]];
                }
                
                newString = [NSString stringWithFormat:@"%@FUNCTION%@", [newString substringToIndex:startLocation - 3], [newString substringFromIndex:startLocation]];
                break;
            }
        }
    }
    
    return newString;
}

- (NSString *)formatString:(NSString *)formula {
    NSString *str = formula;
    NSInteger c = 0;
    for (int i = 0;i < str.length;i++) {
        if ([str characterAtIndex:i] == '+' || [str characterAtIndex:i] == '-' || [str characterAtIndex:i] == '/' ||
            [str characterAtIndex:i] == '*' || [str characterAtIndex:i] == '(' || [str characterAtIndex:i] == ')' ||
            [[str substringWithRange:NSMakeRange(i, 1)] isEqual:@"π"] || [[str substringWithRange:NSMakeRange(i, 1)] isEqual:@"ø"]) {
            
            if (str.length > i + 1) {
                if ([str characterAtIndex:i + 1] == '.') {
                    formula = [formula stringByReplacingCharactersInRange:NSMakeRange(i + 1 + c, 1) withString:@"0."];
                    c++;
                }
            }
        }
    }
    
    NSString *aString;
    float aFloat;
    NSMutableString *formattedString = [[NSMutableString alloc]init];
    
    NSScanner *theScanner = [NSScanner scannerWithString:formula];
    while ([theScanner isAtEnd] == NO) {
        
        if ([theScanner scanFloat:&aFloat]) {
            [formattedString appendString:[NSString stringWithFormat:@"%f",aFloat]];
        }
        
        if ([theScanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&aString]) {
            [formattedString appendString:aString];
        }
    }
    
    return [NSString stringWithString:formattedString];
}

- (BOOL)isUnNumber:(char)c {
    return (c == 'e' || c == 'l' || c == 's' || c == 'c' || c == 't');
}

- (BOOL)isNumber:(char)c {
    return (c == '0' || c == '1' || c == '2' || c == '3' || c == '4' || c == '5' || c == '6' || c == '7' || c == '8' || c == '9');
}

- (NSString *)addImpliedMultiplicationSymbols:(NSString *)oldString {
    NSString *newString = oldString;
    
    for (int i = 0;i < newString.length;i++) {
        if ([self isNumber:[newString characterAtIndex:i]]) {
            if (i > 0 && ([newString characterAtIndex:i - 1] == ')' || [newString characterAtIndex:i - 1] == 'e' || [newString characterAtIndex:i - 1] == 'x' || [[newString substringWithRange:NSMakeRange(i - 1, 1)] isEqualToString:@"π"] || [[newString substringWithRange:NSMakeRange(i - 1, 1)] isEqualToString:@"ø"])) {
                newString = [NSString stringWithFormat:@"%@*%@", [newString substringToIndex:i], [newString substringFromIndex:i]];
                i++;
            } else if (i < newString.length - 1 && ([self isUnNumber:[newString characterAtIndex:i + 1]] || [[newString substringWithRange:NSMakeRange(i + 1, 1)] isEqual:@"π"] || [[newString substringWithRange:NSMakeRange(i + 1, 1)] isEqual:@"ø"] || [newString characterAtIndex:i + 1] == '(' || [newString characterAtIndex:i + 1] == 'x')) {
                newString = [NSString stringWithFormat:@"%@*%@", [newString substringToIndex:i + 1], [newString substringFromIndex:i + 1]];
                i++;
            }
        } else if (i > 0 && [newString characterAtIndex:i] == '(' && [newString characterAtIndex:i - 1] == ')') {
            newString = [NSString stringWithFormat:@"%@*%@", [newString substringToIndex:i], [newString substringFromIndex:i]];
            i++;
        }
    }
    
    return newString;
}

- (int)posNegOrZero:(double)number {
    if (number == 0.0f) {
        return 0;
    }
    
    return (int)(number / fabs(number));
}

@end

@interface NSNumber (Trigonometry)

- (NSNumber*)sin;
- (NSNumber*)cos;
- (NSNumber*)tan;
- (NSNumber*)asin;
- (NSNumber*)acos;
- (NSNumber*)atan;

@end

@implementation NSNumber (Trigonometry)

- (NSNumber *)sin {
    double val = self.doubleValue;
    
    if (round(val / M_PI_2) == val / M_PI_2) {
        int multiple = (int)round(val / M_PI_2) % 4;
        
        switch (multiple) {
            case 0:
                return [NSNumber numberWithDouble:0.0f];
                
            case 1:
                return [NSNumber numberWithDouble:1.0f];
                
            case 2:
                return [NSNumber numberWithDouble:0.0f];
                
            case 3:
                return [NSNumber numberWithDouble:-1.0f];
                
            default:
                break;
        }
    }
    
    return [NSNumber numberWithDouble:sin(val)];
}

- (NSNumber *)cos {
    double val = self.doubleValue;
    
    if (round(val / M_PI_2) == val / M_PI_2) {
        int multiple = (int)round(val / M_PI_2) % 4;
        
        switch (multiple) {
            case 0:
                return [NSNumber numberWithDouble:1.0f];
                
            case 1:
                return [NSNumber numberWithDouble:0.0f];
                
            case 2:
                return [NSNumber numberWithDouble:-1.0f];
                
            case 3:
                return [NSNumber numberWithDouble:0.0f];
                
            default:
                break;
        }
    }
    
    return [NSNumber numberWithDouble:cos(val)];
}

- (NSNumber *)tan {
    double val = self.doubleValue;
    
    if (round(val / M_PI_2) == val / M_PI_2) {
        int multiple = (int)round(val / M_PI_2) % 2;
        
        switch (multiple) {
            case 0:
                return [NSNumber numberWithDouble:0.0f];
                
            case 1:
                return [NSNumber numberWithDouble:NAN];
                
            default:
                break;
        }
    }
    
    return [NSNumber numberWithDouble:tan(val)];
}

- (NSNumber *)asin {
    double result = asin(self.doubleValue);
    return [NSNumber numberWithDouble:result];
}

- (NSNumber *)acos {
    double result = acos(self.doubleValue);
    return [NSNumber numberWithDouble:result];
}

- (NSNumber *)atan {
    double result = atan(self.doubleValue);
    return [NSNumber numberWithDouble:result];
}

- (NSNumber *)dsin {
    double val = self.doubleValue * M_PI / 180.0f;
    
    if (round(val / M_PI_2) == val / M_PI_2) {
        int multiple = (int)round(val / M_PI_2) % 4;
        
        switch (multiple) {
            case 0:
                return [NSNumber numberWithDouble:0.0f];
                
            case 1:
                return [NSNumber numberWithDouble:1.0f];
                
            case 2:
                return [NSNumber numberWithDouble:0.0f];
                
            case 3:
                return [NSNumber numberWithDouble:-1.0f];
                
            default:
                break;
        }
    }
    
    return [NSNumber numberWithDouble:sin(self.doubleValue * M_PI / 180.0f)];
}

- (NSNumber *)dcos {
    double val = self.doubleValue;
    
    if (round(val / M_PI_2) == val / M_PI_2) {
        int multiple = (int)round(val / M_PI_2) % 4;
        
        switch (multiple) {
            case 0:
                return [NSNumber numberWithDouble:1.0f];
                
            case 1:
                return [NSNumber numberWithDouble:0.0f];
                
            case 2:
                return [NSNumber numberWithDouble:-1.0f];
                
            case 3:
                return [NSNumber numberWithDouble:0.0f];
                
            default:
                break;
        }
    }
    
    return [NSNumber numberWithDouble:cos(self.doubleValue * M_PI / 180.0f)];
}

- (NSNumber *)dtan {
    double val = self.doubleValue;
    
    if (round(val / M_PI_2) == val / M_PI_2) {
        int multiple = (int)round(val / M_PI_2) % 2;
        
        switch (multiple) {
            case 0:
                return [NSNumber numberWithDouble:0.0f];
                
            case 1:
                return [NSNumber numberWithDouble:NAN];
                
            default:
                break;
        }
    }
    
    return [NSNumber numberWithDouble:tan(self.doubleValue * M_PI / 180.0f)];
}

- (NSNumber *)dasin {
    double result = asin(self.doubleValue) * 180.0f / M_PI;
    return [NSNumber numberWithDouble:result];
}

- (NSNumber *)dacos {
    double result = acos(self.doubleValue) * 180.0f / M_PI;
    return [NSNumber numberWithDouble:result];
}

- (NSNumber *)datan {
    double result = atan(self.doubleValue) * 180.0f / M_PI;
    return [NSNumber numberWithDouble:result];
}

@end
