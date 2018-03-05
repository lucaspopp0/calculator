//
//  FunctionPad.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/15/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class FunctionPad: ButtonPad {
    
    init(frame: CGRect) {
        super.init(frame: frame, rows: 3, columns: 3, buttons: [])
        
        secondColor = UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 1)
        thirdColor = UIColor(red: 0.2, green: 0.2, blue: 1, alpha: 1)
        disabledAlpha = 0.2
        
        var buttonArray: [Button] = []
        
        buttonArray.append(
            Key(
                title1: "Back"
            )
        )
        
        let activeFunctions: [Function] = Calculator.activeFunctions
        
        // Create a button for each function
        for f: String in Calculator.functionNames {
            let newKey: Key = Key(
                title1: "\(f)(\(Calculator.currentVariable))", value1: "\(f)("
            )
            
            // Disable the button by default
            newKey.enabled1 = false
            
            // If the function is active, enable it
            for function: Function in activeFunctions {
                if function.name == f {
                    newKey.enabled1 = true
                    break
                }
            }
            
            buttonArray.append(newKey)
        }
        
        buttons = buttonArray
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
