//
//  TextLine.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/2/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

/// Generic line of text in a screen
class TextLine: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        font = UIFont(name: "SFMono-Regular", size: font!.pointSize)
        autocapitalizationType = UITextAutocapitalizationType.none
        autocorrectionType = UITextAutocorrectionType.no
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 8, dy: 8)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 8, dy: 7.5)
    }

}

/// Editable line of text
class TextInput: TextLine, UITextFieldDelegate {
    
    override var selectedTextRange: UITextRange? {
        get {
            return super.selectedTextRange
        }
        set {
            if isEnabled && newValue != nil {
                super.selectedTextRange = self.textRange(from: newValue!.start, to: newValue!.start)
            } else {
                super.selectedTextRange = newValue
            }
        }
    }
    
    var cursorPosition: Int {
        get {
            if selectedTextRange != nil {
                return offset(from: beginningOfDocument, to: selectedTextRange!.start)
            } else {
                return -1
            }
        }
        set {
            let position: UITextPosition? = self.position(from: beginningOfDocument, offset: newValue)
            
            if position != nil {
                selectedTextRange = textRange(from: position!, to: position!)
            } else {
                selectedTextRange = nil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isEnabled = true
        
        self.delegate = self
        
        inputView = UIView()
        spellCheckingType = .no
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let controller: CalculatorViewController = UIApplication.shared.keyWindow?.rootViewController as? CalculatorViewController {
            if controller.currentScreen is MainScreen {
                if let enterButton = controller.mainPad.buttonsWith(titles: ["Enter"]).first as? Key {
                    controller.keyPressed(enterButton, onPad: controller.mainPad)
                }
            }
        }
        
        return true
    }
    
}

/// A line of output
class TextOutput: TextLine {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        font = UIFont(name: "SFMono-Regular", size: font!.pointSize)
        isEnabled = false
        textAlignment = .right
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
