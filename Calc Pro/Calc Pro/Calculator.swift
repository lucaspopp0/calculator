//
//  Calculator.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/15/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

enum ButtonStyle {
    case normal
    case line
    case text
}

enum TrigUnits {
    case radians
    case degrees
}

enum GraphType {
    case cartesian
    case polar
}

class Calculator {
    
    static var trigUnits: TrigUnits = .radians
    
    static var graphShowsGridlines: Bool = true {
        didSet {
            while graphScreen.gridlineLayers.count > 0 {
                graphScreen.gridlineLayers.removeFirst().removeFromSuperlayer()
            }
            
            if graphShowsGridlines {
                graphScreen.drawGridlines()
            }
        }
    }
    
    static var graphShowsLabels: Bool = true
    
    static var buttonStyle: ButtonStyle = .line {
        didSet {
            mainPad.refreshButtonAppearances()
            graphPad.refreshButtonAppearances()
        }
    }
    
    static var graphType: GraphType = .cartesian {
        willSet {
            saveFunctions()
        }
        
        didSet {
            mainPad.buttonWithIdentifier(identifier: "Variable")!.title1 = currentVariable
            (mainPad.buttonWithIdentifier(identifier: "Variable") as! Key).value1 = currentVariable
            
            functionScreen.updateGraphType()
            boundsScreen.updateGraphType()
            tableScreen.updateGraphType()
        }
    }
    
    static var tableMin: BoundsValue = BoundsValue(equation: "0", value: 0)
    static var tableMax: BoundsValue = BoundsValue(equation: "10", value: 10)
    static var tableStep: BoundsValue = BoundsValue(equation: "1", value: 1)
    
    static var constants: [Constant] = []
    
    static let functionNames: [String] = ["f", "g", "h", "j", "k", "p", "q", "w"]
    static let functionColors: [UIColor] = [UIColor.red, UIColor.blue, UIColor.green, UIColor.orange, UIColor.purple, UIColor.yellow, UIColor.cyan, UIColor.magenta]
    
    static var cartesianFunctions: [Function] = []
    static var polarFunctions: [Function] = []
    
    static var functions: [Function] {
        get {
            if graphType == .polar {
                return polarFunctions
            }
            
            return cartesianFunctions
        }
    }
    
    static var activeFunctions: [Function] {
        get {
            var output: [Function] = []
            
            for f: Function in functions {
                if !f.equation.isEmpty {
                    output.append(f)
                }
            }
            
            return output
        }
    }
    
    static var currentVariable: String {
        get {
            if graphType == .polar {
                return "θ"
            }
            
            return "x"
        }
    }
    
    static var cartesianBounds: VariableCartesianBounds = VariableCartesianBounds(xMin: -15, xMax: 15, xStep: 2, yMin: -15, yMax: 15, yStep: 2)
    static var polarBounds: VariablePolarBounds = VariablePolarBounds(θMin: BoundsValue(value: 0), θMax: BoundsValue(equation: "2π", value: 2 * Double.pi), θStep: BoundsValue(equation: "π/12", value: Double.pi / 12), rStep: BoundsValue(value: 2), xMin: BoundsValue(value: -15), xMax: BoundsValue(value: 15), yMin: BoundsValue(value: -15), yMax: BoundsValue(value: 15))
    
    static var bounds: VariableBounds {
        get {
            if graphType == .polar {
                return polarBounds
            }
            
            return cartesianBounds
        }
    }
    
    static let mainScreen: MainScreen = MainScreen(frame: CGRect.zero)
    static let functionScreen: FunctionScreen = FunctionScreen(frame: CGRect.zero)
    static let boundsScreen: BoundsScreen = BoundsScreen(frame: CGRect.zero)
    static let graphScreen: GraphScreen = GraphScreen(frame: CGRect.zero)
    static let tableScreen: TableScreen = TableScreen(frame: CGRect.zero)
    
    static let mainPad: MainPad = MainPad(frame: CGRect.zero)
    static let graphPad: GraphPad = GraphPad(frame: CGRect.zero)
    
    static func setup() {
        for i in 0 ..< functionNames.count {
            cartesianFunctions.append(Function(name: functionNames[i], equation: "", color: functionColors[i]))
            polarFunctions.append(Function(name: functionNames[i], equation: "", color: functionColors[i]))
        }
        
        functionScreen.updateGraphType()
        boundsScreen.updateGraphType()
        
        constants.append(Constant(
            name: "Euler's Number",
            variable: "e",
            equation: "\(M_E)",
            value: M_E
        ))
        
        constants.append(Constant(
            name: "Avogadro's Number",
            variable: "L",
            equation: "6.022140857*10^(23)",
            value: 6.022140857e23
        ))
        
        constants.append(Constant(
            name: "Universal Gravitational Constant",
            variable: "G",
            equation: "6.674*10^(-11)",
            value: 6.674e-11
        ))
        
        constants.append(Constant(
            name: "Universal Gas Constant",
            variable: "R",
            equation: "8.31",
            value: 8.31
        ))
        
        constants.append(Constant(
            name: "Vacuum Permittivity",
            variable: "ɛ₀",
            equation: "8.85*10^(-12)",
            value: 8.85e-12
        ))
        
        constants.append(Constant(
            name: "Vacuum Permeability",
            variable: "μ₀",
            equation: "4π*10^(-7)",
            value: 4 * Double.pi * pow(10, -7)
        ))
        
        constants.append(Constant(
            name: "Planck’s Constant",
            variable: "h",
            equation: "6.63*10^(-34)",
            value: 6.63e-34
        ))
    }
    
    static func saveBounds() {
        if graphType == .cartesian {
            for line: TextLine in boundsScreen.lines {
                if line.text == nil {
                    line.text = ""
                }
            }
            
            cartesianBounds.xMin.updateWithEquation(equation: boundsScreen.lines[1].text!)
            cartesianBounds.xMax.updateWithEquation(equation: boundsScreen.lines[2].text!)
            cartesianBounds.xStep.updateWithEquation(equation: boundsScreen.lines[3].text!)
            
            cartesianBounds.yMin.updateWithEquation(equation: boundsScreen.lines[4].text!)
            cartesianBounds.yMax.updateWithEquation(equation: boundsScreen.lines[5].text!)
            cartesianBounds.yStep.updateWithEquation(equation: boundsScreen.lines[6].text!)
            
            tableMin.updateWithEquation(equation: boundsScreen.lines[9].text!)
            tableMax.updateWithEquation(equation: boundsScreen.lines[10].text!)
            tableStep.updateWithEquation(equation: boundsScreen.lines[11].text!)
        } else if graphType == .polar {
            for line: TextLine in boundsScreen.lines {
                if line.text == nil {
                    line.text = ""
                }
            }
            
            polarBounds.θMin.updateWithEquation(equation: boundsScreen.lines[1].text!)
            polarBounds.θMax.updateWithEquation(equation: boundsScreen.lines[2].text!)
            polarBounds.θStep.updateWithEquation(equation: boundsScreen.lines[3].text!)
            polarBounds.rStep.updateWithEquation(equation: boundsScreen.lines[4].text!)
            
            polarBounds.xMin.updateWithEquation(equation: boundsScreen.lines[5].text!)
            polarBounds.xMax.updateWithEquation(equation: boundsScreen.lines[6].text!)
            
            polarBounds.yMin.updateWithEquation(equation: boundsScreen.lines[7].text!)
            polarBounds.yMax.updateWithEquation(equation: boundsScreen.lines[8].text!)
            
            tableMin.updateWithEquation(equation: boundsScreen.lines[11].text!)
            tableMax.updateWithEquation(equation: boundsScreen.lines[12].text!)
            tableStep.updateWithEquation(equation: boundsScreen.lines[13].text!)
        }
    }
    
    static func saveFunctions() {
        if graphType == .cartesian {
            for i in 0 ..< functionScreen.lines.count {
                if functionScreen.lines[i].text != nil {
                    cartesianFunctions[i].equation = functionScreen.lines[i].text!
                } else {
                    cartesianFunctions[i].equation = ""
                }
            }
        } else if graphType == .polar {
            for i in 0 ..< functionScreen.lines.count {
                if functionScreen.lines[i].text != nil {
                    polarFunctions[i].equation = functionScreen.lines[i].text!
                } else {
                    polarFunctions[i].equation = ""
                }
            }
        }
    }
    
    static func functionWithName(name: String) -> Function? {
        for function: Function in functions {
            if function.name == name {
                return function
            }
        }
        
        return nil
    }
    
}
