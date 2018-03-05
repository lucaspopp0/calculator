//
//  Toggle.swift
//  Calc Pro
//
//  Created by Lucas Popp on 4/24/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class Toggle: Button {
    
    /// The value of the toggle. Updates the appearance when changed.
    var on: Bool = false {
        didSet {
            refreshAppearance()
        }
    }
    
    /// The color the toggle should turn when it's on. Updates the appearance when changed.
    var onColor: UIColor? {
        didSet {
            refreshAppearance()
        }
    }
    
    override init(style: Style = .dark,
                  title1: String, identifier1: String? = nil, font1: UIFont = UIFont.boldSystemFont(ofSize: 17),
                  title2: String = "", identifier2: String? = nil, font2: UIFont = UIFont.boldSystemFont(ofSize: 17),
                  title3: String = "", identifier3: String? = nil, font3: UIFont = UIFont.boldSystemFont(ofSize: 17)) {
        super.init(
            style: style,
            title1: title1, identifier1: identifier1, font1: font1,
            title2: title2, identifier2: identifier2, font2: font2,
            title3: title3, identifier3: identifier3, font3: font3
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Toggles the toggle
    func toggle() {
        on = !on
    }
    
    /// Updates the toggle's appearance
    override internal func refreshAppearance(animated: Bool = false) {
        if on && onColor != nil {
            UIView.animate(withDuration: (animated ? 0.15 : 0), animations: {
                self.backgroundColor = self.onColor
                self.setTitleColor(UIColor.white, for: UIControlState())
            }) 
        } else {
            super.refreshAppearance(animated: animated)
        }
    }
    
    override func pressed() {
        toggle()
        pad?.togglePressed(self)
    }
    
}
