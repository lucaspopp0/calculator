//
//  MainPad.swift
//  Calc Pro
//
//  Created by Lucas Popp on 4/24/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class MainPad: ButtonPad {
    
    init(frame: CGRect) {
        super.init(frame: frame, rows: 7, columns: 5, buttons: [])
        
        secondColor = UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 1)
        thirdColor = UIColor(red: 0.2, green: 0.2, blue: 1, alpha: 1)
        disabledAlpha = 0.2
        
        var buttonArray: [Button] = []
        
        buttonArray.append(
            Toggle(
                title1: "2ND"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "Mode"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "x", value1: "x", identifier1: "Variable",
                title2: "Use\nFunctions"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "Const"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "Clear",
                title2: "Clear\nAll",
                title3: "\u{2699}", identifier3: "Settings", font3: UIFont(name: "Apple Symbols", size: 28)!
            )
        )
        
        buttonArray.append(
            Toggle(
                title1: "3RD"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "sin", value1: "sin(",
                title2: "sin\u{207B}\u{00B9}", value2: "asin("
            )
        )
        
        buttonArray.append(
            Key(
                title1: "cos", value1: "cos(",
                title2: "cos\u{207B}\u{00B9}", value2: "acos("
            )
        )
        
        buttonArray.append(
            Key(
                title1: "tan", value1: "tan(",
                title2: "tan\u{207B}\u{00B9}", value2: "atan("
            )
        )
        
        buttonArray.append(
            Key(
                style: .gray,
                title1: "x\u{207F}", value1: "^("
            )
        )
        
        buttonArray.append(
            Key(
                title1: "x\u{00B2}", value1: "^(2)",
                title2: "√", value2: "√("
            )
        )
        
        buttonArray.append(
            Key(
                title1: "(", value1: "("
            )
        )
        
        buttonArray.append(
            Key(
                title1: ")", value1: ")"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "\u{232B}", identifier1: "Delete", font1: UIFont(name: "Apple Symbols", size: 28)!
            )
        )
        
        buttonArray.append(
            Key(
                style: .gray,
                title1: "÷", value1: "/"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "π", value1: "π"
            )
        )
        
        buttonArray.append(
            Key(
                style: .white,
                title1: "7", value1: "7"
            )
        )
        
        buttonArray.append(
            Key(
                style: .white,
                title1: "8", value1: "8"
            )
        )
        
        buttonArray.append(
            Key(
                style: .white,
                title1: "9", value1: "9"
            )
        )
        
        buttonArray.append(
            Key(
                style: .gray,
                title1: "×", value1: "*"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "log", value1: "log(",
                title2: "10\u{02E3}", value2: "10^("
            )
        )
        
        buttonArray.append(
            Key(
                style: .white,
                title1: "4", value1: "4"
            )
        )
        
        buttonArray.append(
            Key(
                style: .white,
                title1: "5", value1: "5"
            )
        )
        
        buttonArray.append(
            Key(
                style: .white,
                title1: "6", value1: "6"
            )
        )
        
        buttonArray.append(
            Key(
                style: .gray,
                title1: "-", value1: "-"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "ln", value1: "ln(",
                title2: "e\u{02E3}", value2: "e^("
            )
        )
        
        buttonArray.append(
            Key(
                style: .white,
                title1: "1", value1: "1"
            )
        )
        
        buttonArray.append(
            Key(
                style: .white,
                title1: "2", value1: "2"
            )
        )
        
        buttonArray.append(
            Key(
                style: .white,
                title1: "3", value1: "3"
            )
        )
        
        buttonArray.append(
            Key(
                style: .gray,
                title1: "+", value1: "+"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "x\u{207B}\u{00B9}", value1: "^(-1)",
                title2: "All"
            )
        )
        
        buttonArray.append(
            Key(
                style: .white,
                title1: "0", value1: "0"
            )
        )
        
        buttonArray.append(
            Key(
                style: .white,
                title1: ".", value1: "."
            )
        )
        
        buttonArray.append(
            Key(
                style: .white,
                title1: "(-)", value1: "-",
                title2: "abs", value2: "abs("
            )
        )
        
        buttonArray.append(
            Key(
                style: .gray,
                title1: "Enter",
                title2: "Ans"
            )
        )
        
        buttons = buttonArray
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
