//
//  SettingsPad.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/21/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

/// Special subclass of Toggle, enabling the cell to change alpha values when toggled
class SettingsToggle: Toggle {
    
    override internal func refreshAppearance(animated: Bool = false) {
        if on && onColor != nil {
            UIView.animate(withDuration: (animated ? 0.15 : 0), animations: {
                self.backgroundColor = self.onColor
                self.setTitleColor(UIColor.white, for: UIControlState())
            })
        } else {
            super.refreshAppearance(animated: animated)
            
            if onColor != nil {
                var alpha: CGFloat = 0
                
                onColor!.getRed(nil, green: nil, blue: nil, alpha: &alpha)
                
                backgroundColor = onColor!.withAlphaComponent(alpha * 0.7)
            }
        }
    }
    
}

/// Used to change the settings
class SettingsPad: PadView {
    
    /// Toggle between radians and degrees
    var radDegSelect: SegmentedSelect = SegmentedSelect(frame: CGRect.zero, options: [])
    
    /// Choose the calculator's graph type
    var graphSelect: SegmentedSelect = SegmentedSelect(frame: CGRect.zero, options: [])
    
    let gridlinesToggle: SettingsToggle = SettingsToggle(title1: "Gridlines On")
    let labelsToggle: SettingsToggle = SettingsToggle(title1: "Labels On")
    
    init(frame: CGRect) {
        super.init(frame: frame, backButtonTitle: "Done")
        
        radDegSelect = SegmentedSelect(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: ButtonPad.defaultRowHeight), options: ["Radians", "Degrees"])
        view.addSubview(radDegSelect)
        
        graphSelect = SegmentedSelect(frame: CGRect(x: 0, y: radDegSelect.frame.origin.y + radDegSelect.frame.size.height + 1 , width: frame.size.width, height: ButtonPad.defaultRowHeight), options: ["Cartesian\nFunctions", "Polar\nFunctions"])
        view.addSubview(graphSelect)
        
        radDegSelect.addTarget(self, action: #selector(SettingsPad.updatePreferences), for: .valueChanged)
        graphSelect.addTarget(self, action: #selector(SettingsPad.updatePreferences), for: .valueChanged)
        
        gridlinesToggle.onColor = UIColor(white: 1, alpha: 0.3)
        gridlinesToggle.frame = CGRect(x: 0, y: graphSelect.frame.origin.y + graphSelect.frame.size.height + 1 , width: frame.size.width, height: ButtonPad.defaultRowHeight)
        view.addSubview(gridlinesToggle)
        
        gridlinesToggle.addTarget(self, action: #selector(SettingsPad.updatePreferences), for: .touchUpInside)
        
        labelsToggle.onColor = UIColor(white: 1, alpha: 0.3)
        labelsToggle.frame = CGRect(x: 0, y: gridlinesToggle.frame.origin.y + gridlinesToggle.frame.size.height + 1 , width: frame.size.width, height: ButtonPad.defaultRowHeight)
        view.addSubview(labelsToggle)
        
        labelsToggle.addTarget(self, action: #selector(SettingsPad.updatePreferences), for: .touchUpInside)
        
        // Update the various controls to the current values
        if Calculator.trigUnits == .degrees {
            radDegSelect.selectOption(option: 1)
        }
        
        if Calculator.graphType == .polar {
            graphSelect.selectOption(option: 1)
        }
        
        if Calculator.graphShowsGridlines {
            gridlinesToggle.on = true
        }
        
        if Calculator.graphShowsLabels {
            labelsToggle.on = true
        }
        
        updatePreferences()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePreferences() {
        // Saves the preferences indicated by the toggles
        
        if radDegSelect.selectedOptionIndex == 0 {
            Calculator.trigUnits = .radians
        } else {
            Calculator.trigUnits = .degrees
        }
        
        if graphSelect.selectedOptionIndex == 0 {
            Calculator.graphType = .cartesian
        } else {
            Calculator.graphType = .polar
        }
        
        Calculator.graphShowsGridlines = gridlinesToggle.on
        Calculator.graphShowsLabels = labelsToggle.on
        
        while Calculator.graphScreen.gridlineLayers.count > 0 {
            Calculator.graphScreen.gridlineLayers.removeFirst().removeFromSuperlayer()
        }
        
        // Update the titles of the toggles
        
        if gridlinesToggle.on {
            gridlinesToggle.title1 = "Gridlines On"
            Calculator.graphScreen.drawGridlines()
        } else {
            gridlinesToggle.title1 = "Gridlines Off"
        }
        
        if labelsToggle.on {
            labelsToggle.title1 = "Labels On"
        } else {
            labelsToggle.title1 = "Labels Off"
        }
    }
    
    override func positionButtons() {
        super.positionButtons()
        
        // Shifts the buttons down 20px to make room for the title bar
        for button: Button in buttons {
            button.frame.origin.y += 20
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Shifts the view down 20px to make room for the title bar
        view.frame.origin.y += 20
        view.frame.size.height -= 20
    }
    
}
