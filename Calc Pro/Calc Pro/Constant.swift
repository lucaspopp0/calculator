//
//  Constant.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/23/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import Foundation

class Constant {
    
    var name: String
    var variable: String
    var equation: String
    var value: Double
    
    init(name: String = "", variable: String = "", equation: String = "", value: Double = 0) {
        self.name = name
        self.variable = variable
        self.equation = equation
        self.value = value
    }
    
}
