//
//  FunctionList.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/15/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

/// Used to display the functions in the GraphScreen
class FunctionList: TextLinesView {
    
    var maxPrefixWidth: CGFloat = 0
    var prefixes: [UILabel] = []
    var colorIndicators: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        Button.darkBackgroundColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        // Set the background color to slightly darker than the default Button dark background color
        backgroundColor = UIColor(hue: h, saturation: s, brightness: b * 0.8, alpha: a)
        
        // Add a tap gesture recognizer for hiding/showing functions on tap
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FunctionList.tapped(sender:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapped(sender: UITapGestureRecognizer) {
        let location: CGPoint = sender.location(in: self)
        
        // Toggle the function that was tapped
        for i in 0 ..< lines.count {
            if lines[i].frame.contains(location) {
                colorIndicators[i].alpha = 1 - colorIndicators[i].alpha
                Calculator.graphScreen.toggleFunction(index: i)
                break
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let topPadding: CGFloat = 8
        
        var currentTop: CGFloat = topPadding
        
        for prefix: UILabel in prefixes {
            maxPrefixWidth = max(prefix.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: lineHeight)).width, maxPrefixWidth)
        }
        
        for line: TextLine in lines {
            line.frame = CGRect(x: 8 + maxPrefixWidth + 4, y: currentTop, width: bounds.size.width - maxPrefixWidth - 4 - 8, height: lineHeight)
            
            currentTop += lineHeight
        }
        
        currentTop = topPadding
        
        for colorIndicator: UIView in colorIndicators {
            colorIndicator.frame = CGRect(x: 0, y: currentTop, width: 6, height: lineHeight)
            
            currentTop += lineHeight
        }
        
        currentTop = topPadding - 1
        
        for prefix: UILabel in prefixes {
            prefix.frame = CGRect(x: 16, y: currentTop, width: maxPrefixWidth, height: lineHeight)
            
            currentTop += lineHeight
        }
    }
    
    /// Remove old lines/prefixes, and create the necessary new prefixes and color indicators
    override func updateLines() {
        super.updateLines()
        
        for prefix: UILabel in prefixes {
            prefix.removeFromSuperview()
        }
        
        prefixes.removeAll()
        
        for background: UIView in colorIndicators {
            background.removeFromSuperview()
        }
        
        colorIndicators.removeAll()
        
        let topPadding: CGFloat = 8
        
        var currentTop: CGFloat = topPadding - 1
        var count: Int = 0
        
        for line: TextLine in lines {
            line.textColor = UIColor.white
            line.isUserInteractionEnabled = false
            line.frame = CGRect(x: 0, y: currentTop, width: bounds.size.width, height: lineHeight)
            
            let newColorIndicator: UIView = UIView(frame: CGRect(x: 0, y: currentTop, width: bounds.size.width, height: lineHeight))
            colorIndicators.append(newColorIndicator)
            
            let newPrefix: UILabel = UILabel(frame: CGRect(x: 0, y: currentTop, width: 0, height: lineHeight))
            newPrefix.font = UIFont(name: "SFMono-Regular", size: newPrefix.font!.pointSize)
            newPrefix.textColor = UIColor.white
            
            maxPrefixWidth = max(newPrefix.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: lineHeight)).width, maxPrefixWidth)
            
            prefixes.append(newPrefix)
            
            insertSubview(newColorIndicator, belowSubview: lines.first!)
            addSubview(newPrefix)
            
            currentTop += lineHeight
            count += 1
            
            bringSubview(toFront: line)
        }
        
        for i in 0 ..< lines.count {
            lines[i].frame = CGRect(x: maxPrefixWidth + 4 + 8, y: lines[i].frame.origin.y, width: bounds.size.width - maxPrefixWidth - 4 - 8, height: lineHeight)
            prefixes[i].frame = CGRect(x: 16, y: prefixes[i].frame.origin.y, width: maxPrefixWidth, height: lineHeight)
            colorIndicators[i].frame = CGRect(x: 0, y: prefixes[i].frame.origin.y, width: 6, height: lineHeight)
        }
    }
    
    /// The functions have changed. Update what is being displayed to match the current functions
    func update() {
        // Clear the current functions
        while lines.count > 0 {
            lines.removeFirst()
        }
        
        let activeFunctions: [Function] = Calculator.activeFunctions
        
        // Create lines for the active functions
        for _ in activeFunctions {
            lines.append(TextLine(frame: CGRect.zero))
        }
        
        updateLines()
        
        // Assign the correct prefixes/colors for the functions
        for i in 0 ..< lines.count {
            prefixes[i].text = "\(activeFunctions[i].name)(\(Calculator.currentVariable))="
            lines[i].text = activeFunctions[i].equation
            colorIndicators[i].backgroundColor = activeFunctions[i].color
        }
        
        layoutSubviews()
    }
    
}
