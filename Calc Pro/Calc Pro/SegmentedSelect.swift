//
//  SegmentedSelect.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/16/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class SegmentedSelect: UIControl {
    
    /// The options for the segmented select
    var options: [Button] = []
    
    /// The index of the current selected option
    var selectedOptionIndex: Int = 0
    
    override var tintColor: UIColor! {
        didSet {
            var alpha: CGFloat = 0
            
            tintColor.getRed(nil, green: nil, blue: nil, alpha: &alpha)
            
            for option: Button in options {
                option.backgroundColor = tintColor.withAlphaComponent(alpha * 0.7)
            }
            
            if options.count < selectedOptionIndex {
                options[selectedOptionIndex].backgroundColor = tintColor
            }
        }
    }
    
    /// The title of the current selected option
    var value: String? {
        get {
            if options.count > 0 {
                return nil
            } else {
                return options[selectedOptionIndex].title1
            }
        }
    }
    
    init(frame: CGRect, options optionTitles: [String]) {
        super.init(frame: frame)
        
        tintColor = UIColor(white: 1, alpha: 0.3)
        
        for optionTitle: String in optionTitles {
            options.append(Button(title1: optionTitle))
        }
        
        for option: Button in options {
            addSubview(option)
            option.refreshAppearance()
            option.addTarget(self, action: #selector(SegmentedSelect.optionTapped(option:)), for: .touchUpInside)
        }
        
        selectOption(option: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let optionWidth: CGFloat = bounds.size.width / CGFloat(options.count)
        
        for i in 0 ..< options.count {
            options[i].frame = CGRect(x: CGFloat(i) * optionWidth, y: 0, width: optionWidth, height: bounds.size.height)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectOption(option: Int) {
        if options.count > option {
            optionTapped(option: options[option])
        }
    }
    
    func optionTapped(option: Button) {
        var alpha: CGFloat = 0
        
        tintColor.getRed(nil, green: nil, blue: nil, alpha: &alpha)
        
        for button: Button in options {
            button.backgroundColor = tintColor.withAlphaComponent(alpha * 0.7)
        }
        
        option.backgroundColor = tintColor
        
        selectedOptionIndex = options.index(of: option)!
        
        sendActions(for: .valueChanged)
    }
    
}
