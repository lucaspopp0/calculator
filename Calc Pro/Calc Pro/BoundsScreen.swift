//
//  BoundsScreen.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/12/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class BoundsScreen: TextScreen {
    
    var maxGraphPrefixWidth: CGFloat = 0
    var maxTablePrefixWidth: CGFloat = 0
    
    var graphPrefixes: [UILabel] = []
    var tablePrefixes: [UILabel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateGraphType()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateGraphType() {
        while lines.count > 0 {
            lines.removeFirst().removeFromSuperview()
        }
        
        while graphPrefixes.count > 0 {
            graphPrefixes.removeFirst().removeFromSuperview()
        }
        
        while tablePrefixes.count > 0 {
            tablePrefixes.removeFirst().removeFromSuperview()
        }
        
        let graphLine: TextLine = TextLine(frame: CGRect.zero)
        graphLine.text = "Graph Bounds"
        graphLine.isUserInteractionEnabled = false
        graphLine.font = UIFont(name: "SFMono-Bold", size: graphLine.font!.pointSize)
        lines.append(graphLine)
        
        if Calculator.graphType == .cartesian {
            let prefixLabels: [String] = ["x-min: ", "x-max: ", "x-step: ", "y-min: ", "y-max: ", "y-step: "]
            
            for label: String in prefixLabels {
                lines.append(TextInput(frame: CGRect.zero))
                
                let newPrefix: UILabel = UILabel(frame: CGRect.zero)
                newPrefix.font = UIFont(name: "SFMono-Regular", size: newPrefix.font!.pointSize)
                newPrefix.text = label
                
                graphPrefixes.append(newPrefix)
            }
            
            lines[1].text = Calculator.cartesianBounds.xMin.equation
            lines[2].text = Calculator.cartesianBounds.xMax.equation
            lines[3].text = Calculator.cartesianBounds.xStep.equation
            
            lines[4].text = Calculator.cartesianBounds.yMin.equation
            lines[5].text = Calculator.cartesianBounds.yMax.equation
            lines[6].text = Calculator.cartesianBounds.yStep.equation
        } else if Calculator.graphType == .polar {
            let prefixLabels: [String] = ["θ-min: ", "θ-max: ", "θ-step: ", "r-step: ", "x-min: ", "x-max: ", "y-min: ", "y-max: "]
            
            for label: String in prefixLabels {
                lines.append(TextInput(frame: CGRect.zero))
                
                let newPrefix: UILabel = UILabel(frame: CGRect.zero)
                newPrefix.font = UIFont(name: "SFMono-Regular", size: newPrefix.font!.pointSize)
                newPrefix.text = label
                
                graphPrefixes.append(newPrefix)
            }
            
            lines[1].text = Calculator.polarBounds.θMin.equation
            lines[2].text = Calculator.polarBounds.θMax.equation
            lines[3].text = Calculator.polarBounds.θStep.equation
            lines[4].text = Calculator.polarBounds.rStep.equation
            
            lines[5].text = Calculator.polarBounds.xMin.equation
            lines[6].text = Calculator.polarBounds.xMax.equation
            
            lines[7].text = Calculator.polarBounds.yMin.equation
            lines[8].text = Calculator.polarBounds.yMax.equation
        }
        
        let blankLine: TextLine = TextLine(frame: CGRect.zero)
        blankLine.isUserInteractionEnabled = false
        blankLine.text = ""
        lines.append(blankLine)
        
        let tableLine: TextLine = TextLine(frame: CGRect.zero)
        tableLine.text = "Table Bounds"
        tableLine.isUserInteractionEnabled = false
        tableLine.font = UIFont(name: "SFMono-Bold", size: graphLine.font!.pointSize)
        lines.append(tableLine)
        
        let prefixLabels: [String] = ["table-min: ", "table-max: ", "table-step: "]
        
        for label: String in prefixLabels {
            lines.append(TextInput(frame: CGRect.zero))
            
            let newPrefix: UILabel = UILabel(frame: CGRect.zero)
            newPrefix.font = UIFont(name: "SFMono-Regular", size: newPrefix.font!.pointSize)
            newPrefix.text = label
            
            tablePrefixes.append(newPrefix)
        }
        
        if Calculator.graphType == .cartesian {
            lines[9].text = "\(Calculator.tableMin.equation)"
            lines[10].text = "\(Calculator.tableMax.equation)"
            lines[11].text = "\(Calculator.tableStep.equation)"
        } else if Calculator.graphType == .polar {
            lines[11].text = "\(Calculator.tableMin.equation)"
            lines[12].text = "\(Calculator.tableMax.equation)"
            lines[13].text = "\(Calculator.tableStep.equation)"
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
        
        Calculator.saveBounds()
    }
    
    func positionLines() {
        var currentTop: CGFloat = 0
        
        var i: Int = 0
        
        lines[i].frame = CGRect(x: 0, y: currentTop, width: bounds.size.width, height: lineHeight)
        currentTop += lineHeight
        
        i += 1
        
        for prefix: UILabel in graphPrefixes {
            prefix.frame = CGRect(x: 8, y: currentTop - 1, width: maxGraphPrefixWidth, height: lineHeight)
            lines[i].frame = CGRect(x: maxGraphPrefixWidth + 4, y: currentTop, width: bounds.size.width - maxGraphPrefixWidth - 4, height: lineHeight)
            
            i += 1
            currentTop += lineHeight
        }
        
        lines[i].frame = CGRect(x: 0, y: currentTop, width: bounds.size.width, height: lineHeight / 2)
        currentTop += lineHeight / 2
        
        i += 1
        
        lines[i].frame = CGRect(x: 0, y: currentTop, width: bounds.size.width, height: lineHeight)
        currentTop += lineHeight
        
        i += 1
        
        for prefix: UILabel in tablePrefixes {
            prefix.frame = CGRect(x: 8, y: currentTop, width: maxTablePrefixWidth, height: lineHeight)
            lines[i].frame = CGRect(x: maxTablePrefixWidth + 4, y: currentTop, width: bounds.size.width - maxTablePrefixWidth - 4, height: lineHeight)
            
            i += 1
            currentTop += lineHeight
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        positionLines()
    }
    
    override func updateLines() {
        super.updateLines()
        
        var i: Int = 0
        
        while i < subviews.count {
            if subviews[i] is UILabel {
                subviews[i].removeFromSuperview()
                i -= 1
            }
            
            i += 1
        }
        
        for prefix: UILabel in graphPrefixes {
            addSubview(prefix)
        }
        
        for prefix: UILabel in tablePrefixes {
            addSubview(prefix)
        }
        
        for prefix: UILabel in graphPrefixes {
            maxGraphPrefixWidth = max(maxGraphPrefixWidth, prefix.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width)
        }
        
        for prefix: UILabel in tablePrefixes {
            maxTablePrefixWidth = max(maxTablePrefixWidth, prefix.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width)
        }
        
        positionLines()
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
    
    override func currentLine() -> TextLine? {
        for line: TextLine in lines {
            if line.isFirstResponder {
                return line
            }
        }
        
        return nil
    }
    
    override func disableButtons(pad: ButtonPad) {
        super.disableButtons(pad: pad)
        
        if pad is MainPad {
            pad.disableButtons(withTitles: ["Bounds"], withIdentifiers: ["Variable"])
        }
    }
    
}
