//
//  FetchingMenuItemManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 26/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class FetchingMenuItemManager {

    static private var fetchTime = CFAbsoluteTimeGetCurrent()
    static private let controller = FetchingMenuItemViewController()
    static private let item = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    static var isFetching = false
    
    static var menuItem: NSMenuItem {
        item.view = controller.view
        return item
    }
    
    static func setFetchTimeToNow() {
        FetchingMenuItemManager.updateMenuItem(withText: "Fetching")
        fetchTime = CFAbsoluteTimeGetCurrent()
    }
    
    static func finish() {
        setFetchTimeToNow()
        isFetching = false
    }
    
    static func start() {
        setFetchTimeToNow()
        isFetching = true
    }
    
    static func changeTextIfAppropriate() {
        let startTime = CFAbsoluteTimeGetCurrent()
        let difference = startTime - FetchingMenuItemManager.fetchTime
        let text: String
        
        if difference >= 8 {
            text = "Finishing"
        }
        else if difference >= 2.5 {
            text = "Adding"
        }
        else {
            text = "Fetching"
        }
        
        FetchingMenuItemManager.updateMenuItem(withText: text)
    }
    
    static func updateMenuItem(withText text: String) {
        DispatchQueue.main.async {
            controller.label.stringValue = text
            item.view = controller.view
        }
    }
    
    static func resetView() {
        item.view = nil
    }
    
}
