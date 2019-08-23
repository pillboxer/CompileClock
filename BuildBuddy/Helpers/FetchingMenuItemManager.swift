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
        fetchTime = CFAbsoluteTimeGetCurrent()
    }
    
    static func finish() {
        updateMenuItem(withText: "Finishing")
        setFetchTimeToNow()
        isFetching = false
    }
    
    static func start() {
        updateMenuItem(withText: "Starting")
        setFetchTimeToNow()
        isFetching = true
    }
    
    static func updateMenuItem(withProjectName name: String, projectNumber: Int, numberOfBuilds: Int) {
        DispatchQueue.main.async {
            controller.projectCountLabel.isHidden = false
            controller.projectNameLabel?.stringValue = "\(name):"
            controller.projectCountLabel.stringValue = "\(projectNumber)/\(numberOfBuilds)"
            item.view = controller.view
        }
    }
    
    static func updateMenuItem(withText text: String) {
        DispatchQueue.main.async {
            controller.projectCountLabel.isHidden = true
            controller.projectNameLabel.stringValue = "\(text)"
            item.view = controller.view
        }
    }
    
    static func resetView() {
        item.view = nil
    }
    
}
