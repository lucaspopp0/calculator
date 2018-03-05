//
//  Button.swift
//  Calc Pro
//
//  Created by Lucas Popp on 4/24/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class Button: UIButton {
    
    /// Default Button background colors
    static let darkBackgroundColor: UIColor = UIColor(white: 0.2, alpha: 1)
    static let grayBackgroundColor: UIColor = UIColor(white: 0.35, alpha: 1)
    
    enum State {
        case first
        case second
        case third
    }
    
    enum Style {
        case dark
        case gray
        case white
    }
    
    /// The pad that contains this button (optional)
    var pad: ButtonPad?
    
    /// The current state of this button. Updates the title and appearance when changed.
    var currentState: State = .first {
        didSet {
            switch activeState {
            case .first:
                setTitle(title1, for: UIControlState())
            case .second:
                setTitle(title2, for: UIControlState())
            case .third:
                setTitle(title3, for: UIControlState())
            }
            
            refreshAppearance(animated: true)
        }
    }
    
    /// The view used to make the button darker/lighter when pressed
    var highlightIndicator: UIView = UIView()
    
    /// Keeps track of whether or not the button is being touched
    var touched: Bool = false {
        didSet {
            self.highlightIndicator.alpha = (touched ? 0.2 : 0)
        }
    }
    
    /// The current button style. Updates the appearance when changed.
    var style: Style = .dark {
        didSet {
            refreshAppearance()
        }
    }
    
    /// Button identifiers. Used to identify the button independent of its title.
    var identifier1: String?
    var identifier2: String?
    var identifier3: String?
    
    /// Fonts to use for the different button states
    var font1: UIFont = UIFont.boldSystemFont(ofSize: 17) {
        didSet {
            if activeState == .first {
                refreshAppearance()
            }
        }
    }
    
    var font2: UIFont = UIFont.boldSystemFont(ofSize: 17) {
        didSet {
            if activeState == .second {
                refreshAppearance()
            }
        }
    }
    
    var font3: UIFont = UIFont.boldSystemFont(ofSize: 17) {
        didSet {
            if activeState == .third {
                refreshAppearance()
            }
        }
    }
    
    /// Titles for the different button states
    var title1: String = "" {
        didSet {
            if activeState == .first {
                setTitle(title1, for: UIControlState())
            }
        }
    }
    
    var title2: String = "" {
        didSet {
            if activeState == .second {
                setTitle(title2, for: UIControlState())
            }
        }
    }
    
    var title3: String = "" {
        didSet {
            if activeState == .third {
                setTitle(title3, for: UIControlState())
            }
        }
    }
    
    /// Keeps track of whether or not the button is enabled in each state
    var enabled1: Bool = true {
        didSet {
            refreshAppearance()
        }
    }
    
    var enabled2: Bool = true {
        didSet {
            refreshAppearance()
        }
    }
    
    var enabled3: Bool = true {
        didSet {
            refreshAppearance()
        }
    }
    
    /// Returns whether or not the button is enabled in its active state
    override var isEnabled: Bool {
        get {
            switch activeState {
            case .first:
                return enabled1
            case .second:
                return enabled2
            case .third:
                return enabled3
            }
        }
        
        set {
            switch activeState {
            case .first:
                enabled1 = newValue
            case .second:
                enabled2 = newValue
            case .third:
                enabled3 = newValue
            }
            
            refreshAppearance()
        }
    }
    
    /// Returns the active state of the button. If there is no title for the current state, the active state will be .first
    var activeState: State {
        get {
            if currentState == .second && title2 != "" {
                return .second
            } else if currentState == .third && title3 != "" {
                return .third
            } else {
                return .first
            }
        }
    }
    
    /// Returns the active identifier of the button
    var activeIdentifier: String? {
        get {
            switch activeState {
            case .first:
                return identifier1
            case .second:
                return identifier2
            case .third:
                return identifier3
            }
        }
    }
    
    /// Returns the active title of the button
    var activeTitle: String {
        get {
            switch activeState {
            case .first:
                return title1
            case .second:
                return title2
            case .third:
                return title3
            }
        }
    }
    
    /// Returns the active font of the button
    var activeFont: UIFont {
        get {
            switch activeState {
            case .first:
                return font1
            case .second:
                return font2
            case .third:
                return font3
            }
        }
    }
    
    /// Views for the red/blue rectangles indicating whether or not the button has a second/third state
    let secondIndicator: UIView = UIView()
    let thirdIndicator: UIView = UIView()
    
    init(style: Style = .dark,
        title1: String, identifier1: String? = nil, font1: UIFont = UIFont.boldSystemFont(ofSize: 17),
        title2: String = "", identifier2: String? = nil, font2: UIFont = UIFont.boldSystemFont(ofSize: 17),
        title3: String = "", identifier3: String? = nil, font3: UIFont = UIFont.boldSystemFont(ofSize: 17)) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.style = style
        
        secondIndicator.isUserInteractionEnabled = false
        thirdIndicator.isUserInteractionEnabled = false
        
        addSubview(secondIndicator)
        addSubview(thirdIndicator)
        
        titleLabel?.textAlignment = NSTextAlignment.center
        
        currentState = .first
        
        self.title1 = title1
        self.title2 = title2
        self.title3 = title3
        
        self.font1 = font1
        self.font2 = font2
        self.font3 = font3
        
        self.identifier1 = identifier1
        self.identifier2 = identifier2
        self.identifier3 = identifier3
        
        setTitle(title1, for: UIControlState())
        
        highlightIndicator = UIView(frame: bounds)
        highlightIndicator.backgroundColor = UIColor.black
        highlightIndicator.alpha = 0
        highlightIndicator.isUserInteractionEnabled = false
        
        addTarget(self, action: #selector(type(of: self).pressed), for: .touchUpInside)
        
        addSubview(highlightIndicator)
        sendSubview(toBack: highlightIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        highlightIndicator.frame = bounds
    }
    
    /// Updates the button's appearance
    internal func refreshAppearance(animated: Bool = false) {
        var backgroundColor: UIColor? = UIColor.black
        var titleColor: UIColor = UIColor.white
        
        let disabledAlpha: CGFloat = (pad == nil ? 0.2 : pad!.disabledAlpha)
        
        // Set the displays of the state indicators
        secondIndicator.isHidden = title2.isEmpty
        secondIndicator.alpha = (enabled2 ? 1 : 0.5)
        thirdIndicator.isHidden = title3.isEmpty
        thirdIndicator.alpha = (enabled3 ? 1 : 0.5)
        
        // Position the state indicators appropriately
        if Calculator.buttonStyle == .line {
            let lineSize: CGSize = CGSize(width: 8, height: 4)
            
            let frame1: CGRect = CGRect(x: bounds.size.width - lineSize.width, y: 0, width: lineSize.width, height: lineSize.height)
            let frame2: CGRect = CGRect(x: bounds.size.width - (2 * lineSize.width), y: 0, width: lineSize.width, height: lineSize.height)
            
            secondIndicator.backgroundColor = pad?.secondColor
            thirdIndicator.backgroundColor = pad?.thirdColor
            
            if !title3.isEmpty {
                thirdIndicator.frame = frame1
                secondIndicator.frame = frame2
            } else {
                secondIndicator.frame = frame1
            }
        }
        
        // Determine the appropriate colors for the background and title
        if activeState == .second {
            backgroundColor = pad?.secondColor
            titleColor = (isEnabled ? UIColor.white : UIColor(white: 1, alpha: disabledAlpha))
        } else if activeState == .third {
            backgroundColor = pad?.thirdColor
            titleColor = (isEnabled ? UIColor.white : UIColor(white: 1, alpha: disabledAlpha))
        } else {
            switch style {
            case .dark:
                backgroundColor = Button.darkBackgroundColor
                titleColor = (isEnabled ? UIColor.white : UIColor(white: 1, alpha: disabledAlpha))
            case .gray:
                backgroundColor = Button.grayBackgroundColor
                titleColor = (isEnabled ? UIColor.white : UIColor(white: 1, alpha: disabledAlpha))
            case .white:
                backgroundColor = UIColor.white
                titleColor = (isEnabled ? UIColor.black : UIColor(white: 0, alpha: disabledAlpha))
            }
        }
        
        // Set the background and title colors
        UIView.animate(withDuration: (animated ? 0.15 : 0), animations: {
            self.backgroundColor = backgroundColor
            self.setTitleColor(titleColor, for: UIControlState())
        }) 
        
        // Update to the active font
        titleLabel!.font = activeFont
        
        // If the title doesn't fit on the button comfortable with the given text size, shrink it until it fits
        if bounds.size.width > 0 && bounds.size.height > 0 {
            var titleSize: CGSize = getSizeOfText(activeTitle, font: titleLabel!.font)
            
            while titleSize.width > bounds.size.width * 0.8 || titleSize.height > bounds.size.height * 0.6 {
                titleLabel!.font = titleLabel!.font.withSize(titleLabel!.font.pointSize - 1)
                titleSize = getSizeOfText(activeTitle, font: titleLabel!.font)
            }
        }
    }
    
    /// Sets the title of the button in the current state. Overrides whatever the pre-existing value was.
    override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        
        if title != nil {
            let titleLines: [String] = title!.components(separatedBy: "\n")
            
            titleLabel!.numberOfLines = titleLines.count
        }
    }
    
    fileprivate func getSizeOfText(_ text: String, font: UIFont = UIFont.boldSystemFont(ofSize: 17)) -> CGSize {
        return NSString(string: text).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font],
            context: nil).size
    }
    
    func pressed() {
        pad?.buttonPressed(self)
    }
    
}
