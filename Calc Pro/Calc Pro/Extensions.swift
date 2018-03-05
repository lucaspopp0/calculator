//
//  Extensions.swift
//  Calc Pro
//
//  Created by Lucas Popp on 7/6/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import Foundation

// Extension on String allowing substrings with integers instead of using the messy Swift Range syntax

public extension String {
    
    var length: Int {
        get {
            return characters.count
        }
    }
    
    func substring(from: Int, to: Int) -> String {
        return substring(with: index(startIndex, offsetBy: from) ..< index(startIndex, offsetBy: to))
    }
    
    func substring(from: Int) -> String {
        return substring(from: from, to: length)
    }
    
    func substring(to: Int) -> String {
        return substring(from: 0, to: to)
    }
    
    func substring(start: Int, length: Int) -> String {
        return substring(from: start, to: start + length)
    }
    
    func characterAt(index: Int) -> String {
        return substring(start: index, length: 1)
    }
    
}

// Extension on NSNumber that allows trig functions and the user's custom functions to be solved in NSExpression

public extension NSNumber {
    
    // MARK: User functions
    
    func f() -> NSNumber {
        return NSNumber(value: Calculator.functionWithName(name: "f")!.evaluate(withValue: doubleValue, forVariable: Calculator.currentVariable))
    }
    
    func g() -> NSNumber {
        return NSNumber(value: Calculator.functionWithName(name: "g")!.evaluate(withValue: doubleValue, forVariable: Calculator.currentVariable))
    }
    
    func h() -> NSNumber {
        return NSNumber(value: Calculator.functionWithName(name: "h")!.evaluate(withValue: doubleValue, forVariable: Calculator.currentVariable))
    }
    
    func j() -> NSNumber {
        return NSNumber(value: Calculator.functionWithName(name: "j")!.evaluate(withValue: doubleValue, forVariable: Calculator.currentVariable))
    }
    
    func k() -> NSNumber {
        return NSNumber(value: Calculator.functionWithName(name: "k")!.evaluate(withValue: doubleValue, forVariable: Calculator.currentVariable))
    }
    
    func p() -> NSNumber {
        return NSNumber(value: Calculator.functionWithName(name: "p")!.evaluate(withValue: doubleValue, forVariable: Calculator.currentVariable))
    }
    
    func q() -> NSNumber {
        return NSNumber(value: Calculator.functionWithName(name: "q")!.evaluate(withValue: doubleValue, forVariable: Calculator.currentVariable))
    }
    
    func w() -> NSNumber {
        return NSNumber(value: Calculator.functionWithName(name: "w")!.evaluate(withValue: doubleValue, forVariable: Calculator.currentVariable))
    }
    
    // MARK: Trig functions using radians
    
    func sin() -> NSNumber {
        return NSNumber(value: Darwin.sin(doubleValue))
    }
    
    func cos() -> NSNumber {
        return NSNumber(value: Darwin.cos(doubleValue))
    }
    
    func tan() -> NSNumber {
        return NSNumber(value: Darwin.tan(doubleValue))
    }
    
    func asin() -> NSNumber {
        return NSNumber(value: Darwin.asin(doubleValue))
    }
    
    func acos() -> NSNumber {
        return NSNumber(value: Darwin.acos(doubleValue))
    }
    
    func atan() -> NSNumber {
        return NSNumber(value: Darwin.atan(doubleValue))
    }
    
    // MARK: Trig functions using degrees
    
    func dsin() -> NSNumber {
        return NSNumber(value: Darwin.sin(doubleValue * Double.pi / 180))
    }
    
    func dcos() -> NSNumber {
        return NSNumber(value: Darwin.cos(doubleValue * Double.pi / 180))
    }
    
    func dtan() -> NSNumber {
        return NSNumber(value: Darwin.tan(doubleValue * Double.pi / 180))
    }
    
    func dasin() -> NSNumber {
        return NSNumber(value: Darwin.asin(doubleValue) * 180 / Double.pi)
    }
    
    func dacos() -> NSNumber {
        return NSNumber(value: Darwin.acos(doubleValue) * 180 / Double.pi)
    }
    
    func datan() -> NSNumber {
        return NSNumber(value: Darwin.atan(doubleValue) * 180 / Double.pi)
    }
    
}
