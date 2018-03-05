//
//  Calculator.h
//  Calculator Pro
//
//  Created by Lucas Popp on 10/16/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Calculator : NSObject

- (id)init;

- (NSString *)replaceVariable:(NSString *)variableName withValue:(double)value inString:(NSString *)formula;

- (NSString *)formatStringForEfficiency:(NSString *)input;

- (NSDictionary *)efficientlyGetValuesForExpression:(NSString *)input;
- (NSDictionary *)efficientlyGetValuesForExpression:(NSString *)input withVariable:(NSString *)variable value:(double)value;

- (double)getDoubleValueOfExpression:(NSString *)input;
- (double)getDoubleValueOfExpression:(NSString *)input withVariable:(NSString *)variable value:(double)value;

- (double)getDoubleValueEfficientlyOfExpression:(NSString *)input;
- (double)getDoubleValueEfficientlyOfExpression:(NSString *)input withVariable:(NSString *)variable value:(double)value;

- (NSString *)evaluateString:(NSString *)input;
- (NSString *)evaluateString:(NSString *)input withVariable:(NSString *)variable value:(double)value;

- (NSString *)efficientlyEvaluateString:(NSString *)input;
- (NSString *)efficientlyEvaluateString:(NSString *)input withVariable:(NSString *)variable value:(double)value;

- (int)posNegOrZero:(double)number;

@end
