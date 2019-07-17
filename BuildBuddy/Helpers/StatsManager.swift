//
//  StatsManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 15/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class StatsManager: NSObject, NSWindowDelegate {
    
    static let shared = StatsManager()
    private var statsWindowController: StatsWindowController?
    
    func showStats() {
        let controller = StatsWindowController(XcodeProjectManager.projects)
        controller.window?.delegate = self
        NSApp.activate(ignoringOtherApps: true)
        statsWindowController = controller
        statsWindowController?.showWindow(nil)
    }
    
    func windowWillClose(_ notification: Notification) {
        statsWindowController = nil
    }
    
    func windowDidResignKey(_ notification: Notification) {
        statsWindowController?.window?.close()
    }
    
}
