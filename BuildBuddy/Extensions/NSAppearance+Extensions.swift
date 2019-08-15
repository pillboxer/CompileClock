//
//  NSAppearance+Extensions.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 15/08/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

extension NSAppearance {
    
    static var isDarkMode: Bool {
        guard let appearance = NSAppearance.current else {
            return false
        }
        return appearance.name == NSAppearance.Name.darkAqua
    }
    
}
