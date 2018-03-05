//
//  GraphPad.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/13/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class GraphPad: ButtonPad {
    
    init(frame: CGRect) {
        super.init(frame: frame, rows: 1, columns: 3, buttons: [])
        
        secondColor = UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 1)
        thirdColor = UIColor(red: 0.2, green: 0.2, blue: 1, alpha: 1)
        disabledAlpha = 0.2
        
        var buttonArray: [Button] = []
        
        buttonArray.append(
            Key(
                title1: "Main"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "Edit\nFunctions"
            )
        )
        
        buttonArray.append(
            Key(
                title1: "Bounds"
            )
        )
        
        buttons = buttonArray
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
