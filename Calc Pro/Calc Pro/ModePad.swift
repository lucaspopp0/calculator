//
//  ModePad.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/16/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

/// Used to switch between the different modes of the calculator
class ModePad: ButtonPad {
    
    init(frame: CGRect) {
        super.init(frame: frame, rows: 6, columns: 1, buttons: [])
        
        secondColor = UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 1)
        thirdColor = UIColor(red: 0.2, green: 0.2, blue: 1, alpha: 1)
        disabledAlpha = 0.2
        
        var buttonArray: [Button] = []
        
        buttonArray.append(
            Key(
                title1: "Back"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "Main"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "Functions"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "Bounds"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "Graph"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "Table"
            )
        )
        
        buttons = buttonArray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
