//
//  TextScreen.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/10/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

/// A screen made of TextLines
class TextScreen: TextLinesView, Screen, ButtonPadDelegate {
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didBecomeActive() {}
    func didGoInactive() {}
    
    func sendText(text: String, fromPad pad: ButtonPad) {
        currentLine()?.insertText(text)
    }
    
    func buttonPressed(_ button: Button, onPad pad: ButtonPad) {}
    
    func keyPressed(_ key: Key, onPad pad: ButtonPad) {
        if key.activeTitle.lowercased() == "clear" {
            currentLine()?.text = ""
        } else if key.identifier1?.lowercased() == "delete" {
            currentLine()?.deleteBackward()
        } else {
            currentLine()?.insertText(key.activeValue)
        }
    }
    
    func togglePressed(_ toggle: Toggle, onPad pad: ButtonPad) {}
    
    func disableButtons(pad: ButtonPad) {
        if pad is MainPad {
            pad.disableButtons(withTitles: ["All"])
        }
    }
    
}
