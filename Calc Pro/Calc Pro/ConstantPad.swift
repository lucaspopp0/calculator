//
//  ConstantPad.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/17/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class ConstantCell: UIControl {
    
    /// The constant to display
    var constant: Constant = Constant()
    
    let titleLabel: UILabel = UILabel()
    let variableLabel: UILabel = UILabel()
    let descriptionLabel: UILabel = UILabel()
    
    /// Used to darken the cell when it's tapped
    let highlightView: UIView = UIView(frame: CGRect.zero)
    
    /// Calculate the cell's height based on its contents
    var heightForCell: CGFloat {
        get {
            var output: CGFloat = 16
            
            output += titleLabel.sizeThatFits(CGSize(width: bounds.size.width - 32, height: CGFloat.greatestFiniteMagnitude)).height + 8
            output += max(variableLabel.sizeThatFits(CGSize(width: bounds.size.width - 32, height: CGFloat.greatestFiniteMagnitude)).height + 8, descriptionLabel.sizeThatFits(CGSize(width: bounds.size.width - 32, height: CGFloat.greatestFiniteMagnitude)).height + 8)
            
            return output
        }
    }
    
    init(frame: CGRect, constant: Constant) {
        super.init(frame: frame)
        
        self.constant = constant
        
        titleLabel.textColor = UIColor.white
        variableLabel.textColor = UIColor.white
        descriptionLabel.textColor = UIColor.white
        
        titleLabel.isUserInteractionEnabled = false
        variableLabel.isUserInteractionEnabled = false
        descriptionLabel.isUserInteractionEnabled = false
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabel.font!.pointSize)
        variableLabel.font = UIFont(name: "SFMono-Regular", size: titleLabel.font!.pointSize)
        descriptionLabel.font = UIFont(name: "SFMono-Regular", size: titleLabel.font!.pointSize)
        
        titleLabel.text = constant.name
        variableLabel.text = constant.variable
        descriptionLabel.text = constant.equation
        
        highlightView.isUserInteractionEnabled = false
        highlightView.backgroundColor = UIColor.white
        highlightView.alpha = 0.2
        
        addSubview(titleLabel)
        addSubview(variableLabel)
        addSubview(descriptionLabel)
        
        addSubview(highlightView)
        sendSubview(toBack: highlightView)
        
        layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // Darken the view when touched
        highlightView.alpha = 0.1
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // Lighten the view when released
        highlightView.alpha = 0.2
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        // Darken the view when released
        highlightView.alpha = 0.2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        highlightView.frame = bounds
        
        titleLabel.frame = CGRect(
            x: 16,
            y: 8,
            width: bounds.size.width - 32,
            height: titleLabel.sizeThatFits(CGSize(width: bounds.size.width - 32, height: CGFloat.greatestFiniteMagnitude)).height + 8
        )
        
        let maxHeight: CGFloat = max(variableLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: bounds.size.height / 2)).height + 8, descriptionLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: bounds.size.height / 2)).height + 8)
        
        variableLabel.frame = CGRect(
            x: 16,
            y: titleLabel.frame.origin.y + titleLabel.frame.size.height,
            width: variableLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: bounds.size.height / 2)).width,
            height: maxHeight
        )
        
        descriptionLabel.textAlignment = .right
        descriptionLabel.frame = CGRect(
            x: 16 + variableLabel.frame.size.width,
            y: titleLabel.frame.origin.y + titleLabel.frame.size.height,
            width: bounds.size.width - 32 - variableLabel.frame.size.width,
            height: maxHeight
        )
    }
    
}

/// Used to type useful constants
class ConstantPad: PadView {
    
    var constantCells: [ConstantCell] = []
    
    init(frame: CGRect) {
        super.init(frame: frame, backButtonTitle: "Cancel")
        
        updateConstants()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        positionCells()
    }
    
    /// Creates cells for the constants
    func updateConstants() {
        while constantCells.count > 0 {
            constantCells.removeFirst().removeFromSuperview()
        }
        
        for constant: Constant in Calculator.constants {
            let constantCell: ConstantCell = ConstantCell(frame: CGRect.zero, constant: constant)
            
            constantCell.addTarget(self, action: #selector(ConstantPad.cellTapped(cell:)), for: .touchUpInside)
            
            constantCells.append(constantCell)
            
            view.addSubview(constantCell)
        }
        
        positionCells()
    }
    
    /// Positions the cells appropriately, and updates the scroll view size
    func positionCells() {
        var currentTop: CGFloat = 0
        
        for cell: ConstantCell in constantCells {
            cell.frame = CGRect(x: 0, y: currentTop, width: view.bounds.size.width, height: cell.heightForCell)
            
            currentTop += cell.heightForCell + 1
        }
        
        view.contentSize = CGSize(width: bounds.size.width, height: currentTop)
    }
    
    func cellTapped(cell: ConstantCell) {
        // Send the value of the constant to the delegate
        delegate?.sendText(text: cell.constant.equation, fromPad: self)
        
        // Mimic pressing the quit button
        delegate?.keyPressed(buttonWithIdentifier(identifier: "Quit") as! Key, onPad: self)
    }
    
}
