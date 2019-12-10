//
//  PreferencesManager.swift
//  CompileClock
//
//  Created by Henry Cooper on 09/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class PreferencesManager: NSObject, NSWindowDelegate {
    
    static let shared = PreferencesManager()
    private var controller: PreferencesWindowController?
    
    func showPreferences() {
        controller?.close()
        controller = PreferencesWindowController()
        NSApp.activate(ignoringOtherApps: true)
        controller?.window?.delegate = self
        controller?.showWindow(nil)
    }
    
    func windowWillClose(_ notification: Notification) {
        controller = nil
    }
    
    
    
    
}
