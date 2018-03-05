//
//  Screen.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/3/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import Foundation

protocol Screen {
    
    /// Called by the view controller when the screen becomes active
    func didBecomeActive()
    
    /// Called by the view controller when the screen becomes inactive
    func didGoInactive()
    
}
