//
//  Brain.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/2/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import Foundation

func round(x: Double, digits: Int) -> Double {
    return round(x * pow(10, Double(digits))) / pow(10, Double(digits))
}

/// Handles all expression evaluation
class Brain {
    
    // Convenient way to use subscript characters. Each contains 0-9
    static let superscripts: [String] = ["\u{2070}", "\u{20B9}", "\u{20B2}", "\u{20B3}", "\u{2074}", "\u{2075}", "\u{2076}", "\u{2077}", "\u{2078}", "\u{2079}"]
    static let subscripts: [String] = ["\u{2080}", "\u{2081}", "\u{2082}", "\u{2083}", "\u{2084}", "\u{2085}", "\u{2086}", "\u{2087}", "\u{2088}", "\u{2089}"]
    
    // MARK: Logic tests
    static func hasBalancedParentheses(input: String) -> Bool {
        var level: Int = 0
        
        for i in 0 ..< input.length {
            if input.characterAt(index: i) == "(" {
                level += 1
            } else if input.characterAt(index: i) == ")" {
                level -= 1
            }
        }
        
        return level == 0
    }
    
    /// Checks if a character is a digit.
    static func isNumber(_ string: String) -> Bool {
        
        return (string == "0" || string == "1" || string == "2" || string == "3" || string == "4" || string == "5" || string == "6" || string == "7" || string == "8" || string == "9")
    }
    
    // MARK: String formatting
    
    /// Formats an equation so it can be evaluated correctly
    static func formatString(input: String) -> String {
        // Fix all decimals with only things after the decimal (like .5, or .2)
        var output: String = input
        
        // If the equation has unbalanced parentheses, it cannot be solved. Return an error
        if !hasBalancedParentheses(input: output) {
            return "ERR: Unbalanced parentheses"
        }
        
        output = fixDecimals(in: output)
        
        output = addImpliedMultiplicationSymbols(to: output)
        output = formatFunctions(in: output)
        output = formatTrigFunctions(in: output)
        
        output = output.replacingOccurrences(of: "√", with: "sqrt")
        output = output.replacingOccurrences(of: "^", with: "**")
        
        output = output.replacingOccurrences(of: "π", with: String(format: "%1.16f", Double.pi))
        output = output.replacingOccurrences(of: "e", with: String(format: "%1.16f", Double.pi))
        
        return output
    }
    
    /// Converts all numbers in an equation to doubles, so there will be no integer math issues. (ex: 10/18 -> 1; 10.0/18.0 -> 1.8)
    static func fixDecimals(in input: String) -> String {
        var output: String = input
        
        // Search through the string and make sure all numbers are complete. Numbers like ".5" and ".23" should be converted to "0.5" and "0.23"
        var index: Int = 0
        
        while index < output.length {
            // If the character at i is a "." and the character before i is not a number, we've found an incomplete decimal
            if output.characterAt(index: index) == "." && (index == 0 || !isNumber(output.characterAt(index: index - 1))) {
                output = output.substring(to: index) + "0" + output.substring(from: index)
                index += 1
            }
            
            index += 1
        }
        
        // Search through the string again and convert all integers to doubles, so there will be no errors with the math
        var numericalStart: Int?
        index = 0
        
        while index < output.length {
            let currentChar: String = output.characterAt(index: index)
            
            if numericalStart == nil {
                if isNumber(currentChar) {
                    numericalStart = index
                }
            }
            
            if numericalStart != nil {
                if !(currentChar == "." || isNumber(currentChar)) {
                    if !output.substring(from: numericalStart!, to: index).contains(".") {
                        output = output.substring(to: index) + ".0" + output.substring(from: index)
                        index += 2
                    }
                    
                    numericalStart = nil
                } else if index == output.length - 1 {
                    if !output.substring(from: numericalStart!).contains(".") {
                        output = output + ".0"
                        index += 2
                    }
                    
                    numericalStart = nil
                }
            }
            
            index += 1
        }
        
        return output
    }
    
    /// Converts all trig functions used in the equation to the specific syntax required by NSExpression
    static func formatTrigFunctions(in input: String) -> String {
        var output: String = input
        
        let trigFunctions: [String] = ["asin", "acos", "atan", "sin", "cos", "tan"]
        
        // There are two sets of trig functions, one for radians and one for degrees. Make sure we're using the correct set
        if Calculator.trigUnits == .radians {
            for trigFunction: String in trigFunctions {
                while output.contains("\(trigFunction)(") {
                    let range: Range = output.range(of: "\(trigFunction)(")!
                    let start: Int = output.distance(from: output.startIndex, to: range.lowerBound)
                    let end: Int = output.distance(from: output.startIndex, to: range.upperBound)
                    var level: Int = 0
                    
                    for i in end - 1 ..< output.length {
                        if output.characterAt(index: i) == "(" {
                            level += 1
                        } else if output.characterAt(index: i) == ")" {
                            level -= 1
                        }
                        
                        if level == 0 {
                            output = output.substring(to: start) + "function" + output.substring(from: end - 1, to: i) + ", \"\(trigFunction)\"" + output.substring(from: i)
                            break
                        }
                    }
                }
            }
        } else {
            for trigFunction: String in trigFunctions {
                while output.contains("\(trigFunction)(") {
                    let range: Range = output.range(of: "\(trigFunction)(")!
                    let start: Int = output.distance(from: output.startIndex, to: range.lowerBound)
                    let end: Int = output.distance(from: output.startIndex, to: range.upperBound)
                    var level: Int = 0
                    
                    for i in end - 1 ..< output.length {
                        if output.characterAt(index: i) == "(" {
                            level += 1
                        } else if output.characterAt(index: i) == ")" {
                            level -= 1
                        }
                        
                        if level == 0 {
                            output = output.substring(to: start) + "function" + output.substring(from: end - 1, to: i) + ", \"d\(trigFunction)\"" + output.substring(from: i)
                            break
                        }
                    }
                }
            }
        }
        
        return output
    }
    
    /// Converts all user functions used in the equation to the specific syntax required by NSExpression
    static func formatFunctions(in input: String) -> String {
        var output: String = input
        
        for f: String in Calculator.functionNames {
            while output.contains("\(f)(") {
                let range: Range = output.range(of: "\(f)(")!
                let start: Int = output.distance(from: output.startIndex, to: range.lowerBound)
                let end: Int = output.distance(from: output.startIndex, to: range.upperBound)
                var level: Int = 0
                
                for i in end - 1 ..< output.length {
                    if output.characterAt(index: i) == "(" {
                        level += 1
                    } else if output.characterAt(index: i) == ")" {
                        level -= 1
                    }
                    
                    if level == 0 {
                        output = output.substring(to: start) + "function" + output.substring(from: end - 1, to: i) + ", \"\(f)\"" + output.substring(from: i)
                        break
                    }
                }
            }
        }
        
        return output
    }
    
    /// Adds implied multiplication symbols to the equation. (ex: (2)(3) -> (2)*(3))
    static func addImpliedMultiplicationSymbols(to input: String) -> String {
        var output: String = input
        
        var i: Int = 0
        
        while i < output.length {
            var previousChar: String?
            let currentChar: String = output.characterAt(index: i)
            var nextChar: String?
            
            if i > 0 {
                previousChar = output.characterAt(index: i - 1)
            }
            
            if i < output.length - 1 {
                nextChar = output.characterAt(index: i + 1)
            }
            
            if isNumber(currentChar) {
                if i > 0 && (previousChar! == ")" || previousChar! == "e" || previousChar! == "x" || previousChar! == "π" || previousChar! == "θ") {
                    // If the current character is a number, and the previous character is either ")", a variable, or a constant, multiplication is implied.
                    
                    output = output.substring(to: i) + "*" + output.substring(from: i)
                    i += 1
                } else if i < output.length - 1 && (["a", "s", "c", "t", "l", "x", "θ", "π", "e", "("].contains(nextChar!) || Calculator.functionNames.contains(nextChar!)) {
                    // If the current character is a number, and the next character is "a", "s", "c", "t", "l", "x", "θ", "π", "e", or "("
                    // or any of the function names, multiplication is implied.
                    
                    output = output.substring(to: i + 1) + "*" + output.substring(from: i + 1)
                    i += 1
                }
            } else if i > 0 && currentChar == "(" && previousChar! == ")" {
                // If the equation has ")(", multiplication is implied between the parentheses
                
                output = output.substring(to: i) + "*" + output.substring(from: i)
                i += 1
            } else if i < output.length - 1 && currentChar == ")" && (["a", "s", "c", "t", "l", "x", "θ", "π", "e"].contains(nextChar!) || Calculator.functionNames.contains(nextChar!)) {
                // If the current character is a closing parenthis, and the next character is "a", "s", "c", "t", "l", "x", "θ", "π", "e",
                // or any of the function names, multiplication is implied.
                
                output = output.substring(to: i + 1) + "*" + output.substring(from: i + 1)
                i += 1
            }
            
            i += 1
        }
        
        return output
    }
    
    /// Replaces all instances of the variable with its value
    static func replaceVariable(variable: String, withValue value: Double, inEquation equation: String) -> String {
        return equation.replacingOccurrences(of: variable, with: "(\(value))")
    }
    
    // MARK: Expression evaluation
    
    /// Formats a string for evaluation, then evaluates it
    static func evaluateString(unFormattedInput: String) -> String {
        return evaluateString(formattedInput: formatString(input: unFormattedInput))
    }
    
    /// Formats a string for evaluation, then returns its numerical value
    static func doubleValueOfExpression(unFormattedInput: String) -> Double {
        return doubleValueOfExpression(formattedInput: formatString(input: unFormattedInput))
    }
    
    /// Formats a string for evaluation, then evaluates it with a variable
    static func evaluateString(unFormattedInput: String, withValue value: Double, forVariable variable: String) -> String {
        return evaluateString(formattedInput: formatString(input: unFormattedInput), withValue: value, forVariable: variable)
    }
    
    /// Formats a string for evaluation using a variable, then returns its numerical value
    static func doubleValueOfExpression(unFormattedInput: String, withValue value: Double, forVariable variable: String) -> Double {
        return doubleValueOfExpression(formattedInput: formatString(input: unFormattedInput), withValue: value, forVariable: variable)
    }
    
    /// Evaluates a pre-formatted string (Faster than evaluateString(input:))
    static func evaluateString(formattedInput: String) -> String {
        var toReturn: String = ""
        
        do {
            try ExceptionHandler.handleException {
                let expression: NSExpression = NSExpression(format: formattedInput)
                toReturn = "\(expression.expressionValue(with: nil, context: nil)!)"
            }
        } catch {
            toReturn = "ERR"
        }
        
        return toReturn
    }
    
    /// Returns the numerical value of a pre-formatted string {
    static func doubleValueOfExpression(formattedInput: String) -> Double {
        let output: Double? = Double(evaluateString(formattedInput: formattedInput))
        
        if output == nil {
            return Double.nan
        }
        
        return output!
    }
    
    /// Evaluates a pre-formatted string using a variable. (Faster than evaluateString(input: , withValue: , forVariable:))
    static func evaluateString(formattedInput: String, withValue value: Double, forVariable variable: String) -> String {
        return evaluateString(formattedInput: replaceVariable(variable: variable, withValue: value, inEquation: formattedInput))
    }
    
    /// Returns the numerical value of a pre-formatted string using a variable. (Faster than evaluateString(input: , withValue: , forVariable:))
    static func doubleValueOfExpression(formattedInput: String, withValue value: Double, forVariable variable: String) -> Double {
        let output: Double? = Double(evaluateString(formattedInput: formattedInput, withValue: value, forVariable: variable))
        
        if output == nil {
            return Double.nan
        }
        
        return output!
    }
    
}
