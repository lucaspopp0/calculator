//
//  FunctionScreen.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/2/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class FunctionScreen: TextScreen {
    
    var maxPrefixWidth: CGFloat = 0
    var prefixes: [UILabel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        for f: String in Calculator.functionNames {
            let newLine: TextInput = TextInput(frame: CGRect.zero)
            
            lines.append(newLine)
            
            let newPrefix: UILabel = UILabel(frame: CGRect.zero)
            newPrefix.font = UIFont(name: "SFMono-Regular", size: newPrefix.font!.pointSize)
            newPrefix.text = "\(f)(\(Calculator.currentVariable))="
            
            prefixes.append(newPrefix)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateGraphType() {
        for i in 0 ..< prefixes.count {
            lines[i].text = Calculator.functions[i].equation
            prefixes[i].text = "\(Calculator.functionNames[i])(\(Calculator.currentVariable))="
        }
        
        updateLines()
        
        lines.first?.becomeFirstResponder()
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        
        lines.first?.becomeFirstResponder()
    }
    
    override func didGoInactive() {
        super.didGoInactive()
        
        Calculator.saveFunctions()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var currentTop: CGFloat = 0
        
        for line: TextLine in lines {
            line.frame = CGRect(x: maxPrefixWidth + 4, y: currentTop, width: bounds.size.width - maxPrefixWidth - 4, height: lineHeight)
            
            currentTop += lineHeight
        }
        
        currentTop = -1
        
        for prefix: UILabel in prefixes {
            prefix.frame = CGRect(x: 8, y: currentTop, width: maxPrefixWidth, height: lineHeight)
            
            currentTop += lineHeight
        }
    }
    
    override func updateLines() {
        super.updateLines()
        
        for prefix: UILabel in prefixes {
            prefix.removeFromSuperview()
        }
        
        var currentTop: CGFloat = -1
        var count: Int = 0
        
        for i in 0 ..< lines.count {
            lines[i].frame = CGRect(x: 0, y: currentTop, width: bounds.size.width, height: lineHeight)
            prefixes[i].frame = CGRect(x: 0, y: currentTop, width: 0, height: lineHeight)
            
            maxPrefixWidth = max(prefixes[i].sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: lineHeight)).width, maxPrefixWidth)
            
            addSubview(prefixes[i])
            
            currentTop += lineHeight
            count += 1
            
            bringSubview(toFront: lines[i])
        }
        
        for i in 0 ..< lines.count {
            lines[i].frame = CGRect(x: maxPrefixWidth + 4, y: lines[i].frame.origin.y, width: bounds.size.width - maxPrefixWidth - 4, height: lineHeight)
            prefixes[i].frame = CGRect(x: 8, y: prefixes[i].frame.origin.y, width: maxPrefixWidth, height: lineHeight)
        }
    }
    
    override func currentLine() -> TextLine? {
        for line: TextLine in lines {
            if line.isFirstResponder {
                return line
            }
        }
        
        return nil
    }
    
    override func keyPressed(_ key: Key, onPad pad: ButtonPad) {
        if key.activeTitle.lowercased() == "clear\nall" {
            for line: TextLine in lines {
                line.text = ""
            }
            
            lines.first!.becomeFirstResponder()
        } else if key.activeTitle.lowercased() == "enter" {
            let current: TextLine? = currentLine()
            
            if current != nil {
                for i in 0 ..< lines.count {
                    if lines[i] == current && i < lines.count - 1 {
                        lines[i + 1].becomeFirstResponder()
                        (lines[i + 1] as! TextInput).cursorPosition = lines[i + 1].text!.length
                        break
                    }
                }
            }
        } else {
            super.keyPressed(key, onPad: pad)
        }
    }
    
    override func disableButtons(pad: ButtonPad) {
        super.disableButtons(pad: pad)
        
        if pad is MainPad {
            pad.disableButtons(withIdentifiers: ["f"])
        }
    }
    
}
