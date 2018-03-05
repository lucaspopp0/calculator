//
//  Key.swift
//  Calc Pro
//
//  Created by Lucas Popp on 4/20/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class Key: Button {
    
    /// The values the key should hold for each state
    var value1: String = ""
    var value2: String = ""
    var value3: String = ""
    
    /// The active value of the key, based on its active state
    var activeValue: String {
        get {
            switch activeState {
            case .first:
                return value1
            case .second:
                return value2
            case .third:
                return value3
            }
        }
    }
    
    init(style: Style = .dark,
         title1: String, value1: String = "", identifier1: String? = nil, font1: UIFont = UIFont.boldSystemFont(ofSize: 17),
         title2: String = "", value2: String = "", identifier2: String? = nil, font2: UIFont = UIFont.boldSystemFont(ofSize: 17),
         title3: String = "", value3: String = "", identifier3: String? = nil, font3: UIFont = UIFont.boldSystemFont(ofSize: 17)) {
        super.init(
            style: style,
            title1: title1, identifier1: identifier1, font1: font1,
            title2: title2, identifier2: identifier2, font2: font2,
            title3: title3, identifier3: identifier3, font3: font3
        )
        
        self.value1 = value1
        self.value2 = value2
        self.value3 = value3
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func pressed() {
        pad?.keyPressed(self)
    }
    
}
