//
//  StatsManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 15/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class StatsManager {
    
    static let controller = StatsWindowController(projects: XcodeProjectManager.namedProjects)
    
    static func showStats() {
        NSApp.activate(ignoringOtherApps: true)
        controller.showWindow(nil)
    }
    
}
