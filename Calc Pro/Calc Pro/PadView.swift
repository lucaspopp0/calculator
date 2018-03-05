//
//  PadView.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/16/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

/// A subclass of ButtonPad, used to create pad-like views, but with a back-button, and a customizeable view
class PadView: ButtonPad {
    
    override var rowHeight: CGFloat {
        get {
            return ButtonPad.defaultRowHeight
        }
    }
    
    /// The customizeable view
    var view: UIScrollView = UIScrollView()
    
    init(frame: CGRect, backButtonTitle: String = "Back") {
        super.init(frame: frame, rows: 1, columns: 1, buttons: [])
        
        secondColor = UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 1)
        thirdColor = UIColor(red: 0.2, green: 0.2, blue: 1, alpha: 1)
        disabledAlpha = 0.2
        
        var buttonArray: [Button] = []
        
        buttonArray.append(
            Key(
                title1: backButtonTitle, identifier1: "Quit"
            )
        )
        
        buttons = buttonArray
        
        backgroundColor = Button.darkBackgroundColor
        view.frame = CGRect(x: 0, y: ButtonPad.defaultRowHeight, width: frame.size.width, height: frame.size.height - ButtonPad.defaultRowHeight)
        
        addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        view.frame = CGRect(x: 0, y: ButtonPad.defaultRowHeight, width: frame.size.width, height: frame.size.height - ButtonPad.defaultRowHeight)
    }
    
}
