//
//  Menu.swift
//  Calc Pro
//
//  Created by Lucas Popp on 4/20/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import Foundation

class MenuCategory {
    
    var title: String
    var items: [String]
    
    init(title: String, items: String...) {
        self.title = title
        self.items = items
    }
    
}

class Menu {
    
    var categories: [MenuCategory]
    
    init(categories: MenuCategory...) {
        self.categories = categories
    }
    
}