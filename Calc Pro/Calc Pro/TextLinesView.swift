//
//  TextLinesView.swift
//  Calc Pro
//
//  Created by Lucas Popp on 4/26/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

/// UIScrollView with many TextLines in it
class TextLinesView: UIScrollView {
    
    /// Default line height
    let lineHeight: CGFloat = 20 + 12
    
    var lines: [TextLine] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var currentTop: CGFloat = 0
        
        // Position each line correctly
        for line: TextLine in lines {
            line.frame = CGRect(x: 0, y: currentTop, width: bounds.size.width, height: lineHeight)
            
            currentTop += lineHeight
        }
    }
    
    /// Remove all lines as subviews from the scrollview, and then re-add all of the correct ones
    func updateLines() {
        var index: Int = 0
        
        while index < subviews.count {
            if subviews[index] is TextLine {
                subviews[index].removeFromSuperview()
                continue
            }
            
            index += 1
        }
        
        var currentTop: CGFloat = 0
        
        for line: TextLine in lines {
            addSubview(line)
            line.frame = CGRect(x: 0, y: currentTop, width: bounds.size.width, height: lineHeight)
            
            currentTop += lineHeight
        }
        
        contentSize = CGSize(width: bounds.size.width, height: currentTop)
    }
    
    func currentLine() -> TextLine? {
        return lines.last
    }
    
}
