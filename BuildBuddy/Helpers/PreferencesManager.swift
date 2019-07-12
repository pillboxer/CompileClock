//
//  PreferencesManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 09/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class PreferencesManager {
    
    static let shared = PreferencesManager()
    let controller = PreferencesWindowController()
    
    private init() {}
    
    func showPreferences() {
        NSApp.activate(ignoringOtherApps: true)
        controller.showWindow(nil)
    }
    
}
