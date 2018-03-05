//
//  TableScreen.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/23/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class TableScreen: UIScrollView, Screen {
    
    var cells: [[UILabel]] = []
    let cellHeight: CGFloat = 20 + 12
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateGraphType()  {
        didBecomeActive()
    }
    
    func didBecomeActive() {
        cells.removeAll()
        
        var independentCol: [UILabel] = []
        
        let headerLabel: UILabel = UILabel(frame: CGRect.zero)
        headerLabel.text = Calculator.currentVariable
        
        independentCol.append(headerLabel)
        
        if Calculator.graphType == .cartesian {
            var currentX: Double = Calculator.tableMin.value
            
            while currentX <= Calculator.tableMax.value {
                let newCell: UILabel = UILabel(frame: CGRect.zero)
                newCell.text = "\(round(x: currentX, digits: 4))"
                independentCol.append(newCell)
                
                currentX += Calculator.tableStep.value
            }
            
            cells.append(independentCol)
            
            for f: Function in Calculator.activeFunctions {
                var col: [UILabel] = []
                
                let h: UILabel = UILabel(frame: CGRect.zero)
                h.text = "\(f.name)(\(Calculator.currentVariable))"
                col.append(h)
                
                currentX = Calculator.tableMin.value
                
                while currentX <= Calculator.tableMax.value {
                    let newCell: UILabel = UILabel(frame: CGRect.zero)
                    newCell.text = "\(round(x: Brain.doubleValueOfExpression(formattedInput: f.formattedEquation!, withValue: currentX, forVariable: "x"), digits: 4))"
                    independentCol.append(newCell)
                    
                    currentX += Calculator.tableStep.value
                }
                
                cells.append(col)
            }
        } else {
            var currentθ: Double = Calculator.tableMin.value
            
            while currentθ <= Calculator.tableMax.value {
                let newCell: UILabel = UILabel(frame: CGRect.zero)
                newCell.text = "\(round(x: currentθ, digits: 4))"
                independentCol.append(newCell)
                
                currentθ += Calculator.polarBounds.nonVariableBounds.θStep
            }
            
            cells.append(independentCol)
            
            for f: Function in Calculator.activeFunctions {
                var col: [UILabel] = []
                
                let h: UILabel = UILabel(frame: CGRect.zero)
                h.text = "\(f.name)(\(Calculator.currentVariable))"
                col.append(h)
                
                currentθ = Calculator.tableMin.value
                
                while currentθ <= Calculator.tableMax.value {
                    let newCell: UILabel = UILabel(frame: CGRect.zero)
                    newCell.text = "\(round(x: Brain.doubleValueOfExpression(formattedInput: f.formattedEquation!, withValue: currentθ, forVariable: "θ"), digits: 4))"
                    independentCol.append(newCell)
                    
                    currentθ += Calculator.tableStep.value
                }
                
                cells.append(col)
            }
        }
        
        updateCells()
    }
    
    func didGoInactive() {}
    
    func positionCells() {
        let cellSize: CGSize = CGSize(width: bounds.size.width / 4, height: cellHeight)
        
        let maxWidth: CGFloat = CGFloat(cells.count) * cellSize.width
        var maxHeight: CGFloat = 0
        
        for c in 0 ..< cells.count {
            let col: [UILabel] = cells[c]
            
            for r in 0 ..< col.count {
                let cell: UILabel = col[r]
                
                addSubview(cell)
                cell.frame = CGRect(x: CGFloat(c) * cellSize.width, y: CGFloat(r) * cellSize.height, width: cellSize.width, height: cellSize.height)
                
                maxHeight = max(maxHeight, CGFloat(r + 1) * cellSize.height)
            }
        }
        
        contentSize = CGSize(width: maxWidth, height: maxHeight)
    }
    
    func updateCells() {
        var index: Int = 0
        
        while index < subviews.count {
            if subviews[index] is UILabel {
                subviews[index].removeFromSuperview()
                continue
            }
            
            index += 1
        }
        
        for col: [UILabel] in cells {
            for cell: UILabel in col {
                addSubview(cell)
                cell.textAlignment = .center
                cell.font = UIFont(name: "SFMono-Regular", size: cell.font!.pointSize)
            }
        }
        
        positionCells()
    }
    
}
