//
//  WelcomeManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 20/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class WelcomeManager: NSObject, NSWindowDelegate {
    
    static let shared = WelcomeManager()
    var controller: WelcomeWindowController?
    
    func showWelcome() {
        controller = WelcomeWindowController()
        print(controller?.window)
        controller?.showWindow(nil)
    }
    
    func windowWillClose(_ notification: Notification) {
        controller = nil
    }
    
    
}
