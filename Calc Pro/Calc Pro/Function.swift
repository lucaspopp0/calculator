//
//  Function.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/13/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class Function {
    
    /// The name of the function. (ex: "f" or "g")
    var name: String
    
    /// The equation for the function as the user typed it
    var equation: String {
        didSet {
            formattedEquation = Brain.formatString(input: equation)
        }
    }
    
    /// The equation for the function, formatted for evaluation
    var formattedEquation: String?
    
    /// The color to use when graphing the function
    var color: UIColor
    
    init(name: String, equation: String, color: UIColor) {
        self.name = name
        self.equation = equation
        self.color = color
        
        formattedEquation = Brain.formatString(input: equation)
    }
    
    /// Returns the numerical value of the function using a variable
    func evaluate(withValue value: Double, forVariable variable: String) -> Double {
        return Brain.doubleValueOfExpression(formattedInput: formattedEquation!, withValue: value, forVariable: variable)
    }
    
}
