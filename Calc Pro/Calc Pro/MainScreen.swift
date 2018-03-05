//
//  MainScreen.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/2/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class MainScreen: TextScreen {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainScreen.tapped(sender:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        
        lines.last?.becomeFirstResponder()
    }
    
    func tapped(sender: UITapGestureRecognizer) {
        let location: CGPoint = sender.location(in: self)
        
        for line: TextLine in lines {
            if line.frame.contains(location) && line != lines.last! {
                currentLine()?.insertText(line.text!)
                break
            }
        }
    }
    
    /// Creates a new line and adds it to the bottom
    func newLine(isOutput: Bool = false) {
        // Disable the previous line
        currentLine()?.isUserInteractionEnabled = false
        
        var newLine: TextLine = TextLine()
        
        if isOutput {
            newLine = TextOutput(frame: CGRect.zero)
        } else {
            newLine = TextInput(frame: CGRect.zero)
        }
        
        lines.append(newLine)
        updateLines()
        
        if !isOutput {
            newLine.becomeFirstResponder()
        }
        
        scrollRectToVisible(CGRect(x: 0, y: 0, width: bounds.size.width, height: lineHeight * CGFloat(lines.count)), animated: true)
    }
    
    override func keyPressed(_ key: Key, onPad pad: ButtonPad) {
        if key.activeTitle.lowercased() == "clear\nall" {
            lines = []
            updateLines()
            newLine()
        } else if key.activeTitle.lowercased() == "enter" && currentLine()!.text != "" {
            let evaluated: String = Brain.evaluateString(unFormattedInput: currentLine()!.text!)
            newLine(isOutput: true)
            currentLine()?.text = evaluated
            newLine()
        } else if key.activeTitle.lowercased() == "ans" {
            if lines.count > 1 {
                let ans: String = lines[lines.count - 2].text!
                
                currentLine()?.insertText(ans)
            }
        } else {
            if lines.count > 1 && (currentLine() as! TextInput).cursorPosition == 0 {
                if key.activeTitle != "(-)" && ["+", "-", "*", "/", "^(", "^(-1)", "^(2)"].contains(key.activeValue) {
                    let ans: String = lines[lines.count - 2].text!
                    
                    currentLine()?.insertText(ans)
                }
            }
            
            super.keyPressed(key, onPad: pad)
        }
    }
    
    override func disableButtons(pad: ButtonPad) {
        super.disableButtons(pad: pad)
        
        if pad is MainPad {
             pad.disableButtons(withTitles: ["Quit"], withIdentifiers: ["Variable"])
        }
    }
    
}
