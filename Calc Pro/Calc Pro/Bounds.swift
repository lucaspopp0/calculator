//
//  Bounds.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/13/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import Foundation
import CoreGraphics

/// Generic protocol for a graph bounds object, where all values are numbers
protocol Bounds {
    
    var xMin: Double { get set }
    var xMax: Double { get set }
    var yMin: Double { get set }
    var yMax: Double { get set }
    
    var xRange: Double { get }
    var yRange: Double { get }
    
    /// Returns whether or not the bounds are valid
    var areValid: Bool { get }
    
}

/// Generic protocol for a graph bounds object, where values can be represented by equations or numbers
protocol VariableBounds {
    
    var xMin: BoundsValue { get set }
    var xMax: BoundsValue { get set }
    var yMin: BoundsValue { get set }
    var yMax: BoundsValue { get set }
    
    var xRange: Double { get }
    var yRange: Double { get }
    
    /// Returns whether or not the bounds are valid
    var areValid: Bool { get }
    
}

/// A value used in VariableBounds to represent both an equation and a number
class BoundsValue {
    
    /// The numerical value
    var value: Double
    
    /// The equation to evaluate
    var equation: String
    
    init(equation: String, value: Double) {
        self.equation = equation
        self.value = value
    }
    
    convenience init(value: Double) {
        self.init(equation: "\(value)", value: value)
    }
    
    /// Updates the equation, and updates the numerical value
    func updateWithEquation(equation: String) {
        self.equation = equation
        value = Brain.doubleValueOfExpression(unFormattedInput: equation)
    }
    
}

/// Standard bounds used for cartesian graphing
class CartesianBounds: Bounds {
    
    var xMin: Double
    var xMax: Double
    var xStep: Double
    
    var yMin: Double
    var yMax: Double
    var yStep: Double
    
    var xRange: Double {
        get {
            return xMax - xMin
        }
    }
    
    var yRange: Double {
        get {
            return yMax - yMin
        }
    }
    
    var areValid: Bool {
        return xRange > 0 && yRange > 0
    }
    
    /// Converts the bounds to variable form
    var variableBounds: VariableCartesianBounds {
        get {
            return VariableCartesianBounds(xMin: BoundsValue(value: xMin), xMax: BoundsValue(value: xMax), xStep: BoundsValue(value: xStep), yMin: BoundsValue(value: yMin), yMax: BoundsValue(value: yMax), yStep: BoundsValue(value: yStep))
        }
    }
    
    /// Creates an instance of CartesianBounds where all variables equal zero
    static var zero: CartesianBounds {
        get {
            return CartesianBounds(xMin: 0, xMax: 0, xStep: 0, yMin: 0, yMax: 0, yStep: 0)
        }
    }
    
    init(xMin: Double, xMax: Double, xStep: Double, yMin: Double, yMax: Double, yStep: Double) {
        self.xMin = xMin
        self.xMax = xMax
        self.xStep = xStep
        
        self.yMin = yMin
        self.yMax = yMax
        self.yStep = yStep
    }
    
    /// Initialize using a variable version
    init(variable: VariableCartesianBounds) {
        self.xMin = variable.xMin.value
        self.xMax = variable.xMax.value
        self.xStep = variable.xStep.value
        
        self.yMin = variable.yMin.value
        self.yMax = variable.yMax.value
        self.yStep = variable.yStep.value
    }
    
}

/// Variable bounds for cartesian graphing
class VariableCartesianBounds: VariableBounds {
    
    var xMin: BoundsValue
    var xMax: BoundsValue
    var xStep: BoundsValue
    
    var yMin: BoundsValue
    var yMax: BoundsValue
    var yStep: BoundsValue
    
    var xRange: Double {
        get {
            return xMax.value - xMin.value
        }
    }
    
    var yRange: Double {
        get {
            return yMax.value - yMin.value
        }
    }
    
    var areValid: Bool {
        return xRange > 0 && yRange > 0
    }
    
    /// Converts the bounds to standard form
    var nonVariableBounds: CartesianBounds {
        get {
            return CartesianBounds(xMin: xMin.value, xMax: xMax.value, xStep: xStep.value, yMin: yMin.value, yMax: yMax.value, yStep: yStep.value)
        }
    }
    
    /// Creates an instance of VariableCartesianBounds where all variables equal zero
    static var zero: VariableCartesianBounds {
        get {
            return VariableCartesianBounds(xMin: BoundsValue(value: 0), xMax: BoundsValue(value: 0), xStep: BoundsValue(value: 1), yMin: BoundsValue(value: 0), yMax: BoundsValue(value: 0), yStep: BoundsValue(value: 1))
        }
    }
    
    init(xMin: BoundsValue, xMax: BoundsValue, xStep: BoundsValue, yMin: BoundsValue, yMax: BoundsValue, yStep: BoundsValue) {
        self.xMin = xMin
        self.xMax = xMax
        self.xStep = xStep
        
        self.yMin = yMin
        self.yMax = yMax
        self.yStep = yStep
    }
    
    /// Initialize using numerical values
    init(xMin: Double, xMax: Double, xStep: Double, yMin: Double, yMax: Double, yStep: Double) {
        self.xMin = BoundsValue(value: xMin)
        self.xMax = BoundsValue(value: xMax)
        self.xStep = BoundsValue(value: xStep)
        
        self.yMin = BoundsValue(value: yMin)
        self.yMax = BoundsValue(value: yMax)
        self.yStep = BoundsValue(value: yStep)
    }
    
    /// Initialize using a standard version
    convenience init(nonVariable: CartesianBounds) {
        self.init(xMin: nonVariable.xMin, xMax: nonVariable.xMax, xStep: nonVariable.xStep, yMin: nonVariable.yMin, yMax: nonVariable.yMax, yStep: nonVariable.yStep)
    }
    
}

/// Standard bounds used for polar graphing
class PolarBounds: Bounds {
    
    var θMin: Double
    var θMax: Double
    var θStep: Double
    var rStep: Double
    
    var xMin: Double
    var xMax: Double
    
    var yMin: Double
    var yMax: Double
    
    var xRange: Double {
        get {
            return xMax - xMin
        }
    }
    
    var yRange: Double {
        get {
            return yMax - yMin
        }
    }
    
    var θRange: Double {
        get {
            return θMax - θMin
        }
    }
    
    var areValid: Bool {
        return xRange > 0 && yRange > 0 && θRange > 0
    }
    
    /// Converts the bounds to variable form
    var variableBounds: VariablePolarBounds {
        get {
            return VariablePolarBounds(θMin: BoundsValue(value: θMin), θMax: BoundsValue(value: θMax), θStep: BoundsValue(value: θStep), rStep: BoundsValue(value: rStep), xMin: BoundsValue(value: xMin), xMax: BoundsValue(value: xMax), yMin: BoundsValue(value: yMin), yMax: BoundsValue(value: yMax))
        }
    }
    
    /// Creates an instance of PolarBounds where all variables are zero
    static var zero: PolarBounds {
        get {
            return PolarBounds(θMin: 0, θMax: 0, θStep: Double.pi / 12, rStep: 2, xMin: 0, xMax: 0, yMin: 0, yMax: 0)
        }
    }
    
    init(θMin: Double, θMax: Double, θStep: Double, rStep: Double, xMin: Double, xMax: Double, yMin: Double, yMax: Double) {
        self.θMin = θMin
        self.θMax = θMax
        self.θStep = θStep
        self.rStep = rStep
        
        self.xMin = xMin
        self.xMax = xMax
        
        self.yMin = yMin
        self.yMax = yMax
    }
    
    /// Initialize using a variable version
    init(variable: VariablePolarBounds) {
        self.θMin = variable.θMin.value
        self.θMax = variable.θMax.value
        self.θStep = variable.θStep.value
        self.rStep = variable.rStep.value
        
        self.xMin = variable.xMin.value
        self.xMax = variable.xMax.value
        
        self.yMin = variable.yMin.value
        self.yMax = variable.yMax.value
    }
    
}

class VariablePolarBounds: VariableBounds {
    
    var θMin: BoundsValue
    var θMax: BoundsValue
    var θStep: BoundsValue
    var rStep: BoundsValue
    
    var xMin: BoundsValue
    var xMax: BoundsValue
    var yMin: BoundsValue
    var yMax: BoundsValue
    
    var xRange: Double {
        get {
            return xMax.value - xMin.value
        }
    }
    
    var yRange: Double {
        get {
            return yMax.value - yMin.value
        }
    }
    
    var θRange: Double {
        get {
            return θMax.value - θMin.value
        }
    }
    
    var areValid: Bool {
        return xRange > 0 && yRange > 0 && θRange > 0
    }
    
    /// Converts the bounds to standard form
    var nonVariableBounds: PolarBounds {
        get {
            return PolarBounds(θMin: θMin.value, θMax: θMax.value, θStep: θStep.value, rStep: rStep.value, xMin: xMin.value, xMax: xMax.value, yMin: yMin.value, yMax: yMax.value)
        }
    }
    
    /// Creates an instance of VariablePolarBounds where all variables equal zero
    static var zero: VariablePolarBounds {
        get {
            return VariablePolarBounds(θMin: BoundsValue(value: 0), θMax: BoundsValue(value: 0), θStep: BoundsValue(value: Double.pi / 12), rStep: BoundsValue(value: 2), xMin: BoundsValue(value: 0), xMax: BoundsValue(value: 0), yMin: BoundsValue(value: 0), yMax: BoundsValue(value: 0))
        }
    }
    
    init(θMin: BoundsValue, θMax: BoundsValue, θStep: BoundsValue, rStep: BoundsValue, xMin: BoundsValue, xMax: BoundsValue, yMin: BoundsValue, yMax: BoundsValue) {
        self.θMin = θMin
        self.θMax = θMax
        self.θStep = θStep
        self.rStep = rStep
        
        self.xMin = xMin
        self.xMax = xMax
        
        self.yMin = yMin
        self.yMax = yMax
    }
    
    /// Initialize using numerical values
    init(θMin: Double, θMax: Double, θStep: Double, rStep: Double, xMin: Double, xMax: Double, yMin: Double, yMax: Double) {
        self.θMin = BoundsValue(value: θMin)
        self.θMax = BoundsValue(value: θMax)
        self.θStep = BoundsValue(value: θStep)
        self.rStep = BoundsValue(value: rStep)
        
        self.xMin = BoundsValue(value: xMin)
        self.xMax = BoundsValue(value: xMax)
        
        self.yMin = BoundsValue(value: yMin)
        self.yMax = BoundsValue(value: yMax)
    }
    
    /// Initialize using a standard version
    convenience init(nonVariable: PolarBounds) {
        self.init(θMin: nonVariable.θMin, θMax: nonVariable.θMax, θStep: nonVariable.θStep, rStep: nonVariable.rStep, xMin: nonVariable.xMin, xMax: nonVariable.xMax, yMin: nonVariable.yMin, yMax: nonVariable.yMax)
    }
    
}
