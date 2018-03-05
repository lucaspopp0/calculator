//
//  ButtonPad.swift
//  Calc Pro
//
//  Created by Lucas Popp on 4/20/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

protocol ButtonPadDelegate {
    
    func keyPressed(_ key: Key, onPad pad: ButtonPad)
    func togglePressed(_ toggle: Toggle, onPad pad: ButtonPad)
    func buttonPressed(_ button: Button, onPad pad: ButtonPad)
    
    /// Send text to the input, without a button press
    func sendText(text: String, fromPad pad: ButtonPad)
    
    /// Disables specific buttons for a given pad
    func disableButtons(pad: ButtonPad)
    
}

class ButtonPad: UIView {
    
    var delegate: ButtonPadDelegate?
    
    /// Default row height for all button pads
    static let defaultRowHeight: CGFloat = ((2/3) * (UIScreen.main.bounds.size.height - 20)) / 7
    
    /// The default height for this button pad given the number of rows
    var defaultHeight: CGFloat {
        get {
            return ButtonPad.defaultRowHeight * CGFloat(rows)
        }
    }
    
    var rows: Int = 1
    var columns: Int = 1
    
    /// Calculated height of the pad's rows
    var rowHeight: CGFloat {
        get {
            return frame.size.height / CGFloat(rows)
        }
    }
    
    /// Calculated width of the pad's columns
    var columnWidth: CGFloat {
        get {
            return frame.size.width / CGFloat(columns)
        }
    }
    
    /// Buttons belonging to the pad. Cannot have values appended or deleted. Should be updated by replacing the array
    var buttons: [Button] = [] {
        willSet {
            for button: Button in buttons {
                button.removeFromSuperview()
            }
        }
        
        didSet {
            for button: Button in buttons {
                button.pad = self
                addSubview(button)
                
                button.isUserInteractionEnabled = false
                
                if button is Toggle {
                    if button.title1 == "2ND" {
                        secondToggle = button as? Toggle
                    } else if button.title1 == "3RD" {
                        thirdToggle = button as? Toggle
                    }
                }
            }
            
            positionButtons()
        }
    }
    
    /// The state of the button pad. Updates the states of all buttons as well
    var state: Button.State = .first {
        didSet {
            for button: Button in buttons {
                button.currentState = state
            }
        }
    }
    
    /// The pad's assigned second toggle
    var secondToggle: Toggle? {
        didSet {
            if secondToggle != nil {
                secondToggle!.onColor = secondColor
            }
        }
    }
    
    /// The pad's assigned third toggle
    var thirdToggle: Toggle? {
        didSet {
            if thirdToggle != nil {
                thirdToggle!.onColor = thirdColor
            }
        }
    }
    
    /// Used to prevent duplicate taps when the user only tapped once. tapCancelled indicates whether or not UITapGestureRecognizer should register a tap
    var tapCancelled: Bool = false
    
    /// Used to prevent duplicate taps when the user only tapped once. touchCancelled indicates whether or not the view's methods should register touch events
    var touchCancelled: Bool = false
    
    /// Appearance values for the pad
    var secondColor: UIColor?
    var thirdColor: UIColor?
    var disabledAlpha: CGFloat = 0.2
    
    init(frame: CGRect, rows: Int, columns: Int, buttons: [Button]) {
        super.init(frame: frame)
        
        isMultipleTouchEnabled = false
        
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ButtonPad.tapped(recognizer:)))
        tapRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(tapRecognizer)
        
        self.rows = rows
        self.columns = columns
        self.buttons =  buttons
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func tapped(recognizer: UITapGestureRecognizer) {
        let location: CGPoint = recognizer.location(in: self)
        let button: Button? = buttonAt(location)
        
        if button != nil && button!.isEnabled {
            // Prevent the view from responding to the same touch
            touchCancelled = true
            
            if !tapCancelled {  // If the recognizer hasn't been disabled, send the events
                button!.sendActions(for: .touchUpInside)
            } else {    // Otherwise, enable the recognizer without sending events
                tapCancelled = false
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        positionButtons()
    }
    
    /// Returns the button at a specific point on the pad, if there is one
    func buttonAt(_ point: CGPoint) -> Button? {
        for button: Button in buttons {
            if button.frame.contains(point) {
                return button
            }
        }
        
        return nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // Remove all button highlights
        for button: Button in buttons {
            button.touched = false
        }
        
        let location: CGPoint = touches.first!.location(in: self)
        let button: Button? = buttonAt(location)
        
        if button != nil && button!.isEnabled {
            // Highlight the button being touched
            button!.touched = true
            
            // If the button is a toggle and the toggle is off, turn it on. Then disable the tapGestureRecognizer so it doesn't register the same touch
            if button! is Toggle && !(button as! Toggle).on {
                button!.sendActions(for: .touchUpInside)
                tapCancelled = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        // Remove all button highlights
        for button: Button in buttons {
            button.touched = false
        }
        
        let location: CGPoint = touches.first!.location(in: self)
        let button: Button? = buttonAt(location)
        
        if button != nil && button!.isEnabled {
            // Highlight the button being touched
            button!.touched = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // Remove all button highlights
        for button: Button in buttons {
            button.touched = false
        }
        
        let location: CGPoint = touches.first!.location(in: self)
        let button: Button? = buttonAt(location)
        
        if button != nil && button!.isEnabled {
            // Enable the tapGestureRecognizer
            tapCancelled = false
            
            if !touchCancelled {    // If touches haven't been cancelled, send actions for the button
                button!.sendActions(for: .touchUpInside)
            } else {    // Otherwise, enable touches
                touchCancelled = false
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        // Remove all button highlights
        for button: Button in buttons {
            button.touched = false
        }
    }
    
    /// Return all buttons with any of the given titles
    func buttonsWith(titles: [String]) -> [Button] {
        var output: [Button] = []
        
        for button: Button in buttons {
            for title: String in titles {
                if button.title1 == title || button.title2 == title || button.title3 == title {
                    output.append(button)
                    break
                }
            }
        }
        
        return output
    }
    
    /// Return all buttons with any of the given identifiers
    func buttonWithIdentifier(identifier: String) -> Button? {
        for button: Button in buttons {
            if (button.identifier1 != nil && button.identifier1 == identifier) || (button.identifier2 != nil && button.identifier2 == identifier) || (button.identifier3 != nil && button.identifier3 == identifier) {
                return button
            }
        }
        
        return nil
    }
    
    /// Disable buttons with given titles/identifiers, for the appropriate states of those titles/identifiers
    func disableButtons(withTitles titles: [String] = [], withIdentifiers identifiers: [String] = []) {
        for button: Button in buttons {
            for title: String in titles {
                if button.title1 == title {
                    button.enabled1 = false
                }
                
                if button.title2 == title {
                    button.enabled2 = false
                }
                
                if button.title3 == title {
                    button.enabled3 = false
                }
            }
            
            for identifier: String in identifiers {
                if button.identifier1 == identifier {
                    button.enabled1 = false
                }
                
                if button.identifier2 == identifier {
                    button.enabled2 = false
                }
                
                if button.identifier3 == identifier {
                    button.enabled3 = false
                }
            }
        }
    }
    
    /// Enable buttons with given titles/identifiers, for the appropriate states of those titles/identifiers
    func enableButtons(withTitles titles: [String] = [], withIdentifiers identifiers: [String] = []) {
        for button: Button in buttons {
            for title: String in titles {
                if button.title1 == title {
                    button.enabled1 = true
                }
                
                if button.title2 == title {
                    button.enabled2 = true
                }
                
                if button.title3 == title {
                    button.enabled3 = true
                }
            }
            
            for identifier: String in identifiers {
                if button.identifier1 == identifier {
                    button.enabled1 = true
                }
                
                if button.identifier2 == identifier {
                    button.enabled2 = true
                }
                
                if button.identifier3 == identifier {
                    button.enabled3 = true
                }
            }
        }
    }
    
    func enableAllButtons() {
        for button: Button in buttons {
            button.enabled1 = true
            button.enabled2 = true
            button.enabled3 = true
        }
    }
    
    func positionButtons() {
        var column: Int = 0
        var row: Int = 0
        
        for button: Button in buttons {
            button.frame = CGRect(
                x: CGFloat(column) * columnWidth,
                y: CGFloat(row) * rowHeight,
                width: columnWidth,
                height: rowHeight
            )
            
            column += 1
            
            if column >= columns {
                column = 0
                row += 1
            }
            
            button.refreshAppearance()
        }
    }
    
    func refreshButtonAppearances() {
        for button: Button in buttons {
            button.refreshAppearance()
        }
    }
    
    func sendText(text: String, fromPad pad: ButtonPad) {
        delegate?.sendText(text: text, fromPad: pad)
    }
    
    func buttonPressed(_ button: Button) {
        delegate?.buttonPressed(button, onPad: self)
    }
    
    func keyPressed(_ key: Key) {
        delegate?.keyPressed(key, onPad: self)
        
        if state == .second && secondToggle != nil {
            secondToggle!.pressed()
        } else if state == .third && thirdToggle != nil {
            thirdToggle!.pressed()
        }
    }
    
    func togglePressed(_ toggle: Toggle) {
        if toggle == secondToggle {
            if toggle.on {
                state = .second
            } else {
                state = .first
            }
            
            if thirdToggle != nil {
                thirdToggle!.on = false
            }
        } else if toggle == thirdToggle {
            if toggle.on {
                state = .third
            } else {
                state = .first
            }
            
            if secondToggle != nil {
                secondToggle!.on = false
            }
        }
        
        delegate?.togglePressed(toggle, onPad: self)
    }
    
}
