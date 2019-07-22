//
//  NSWindow+Extensions.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 22/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

extension NSWindow {
    
    func animateToStatusItem() {
        if let statusItemFrame = AppDelegate.shared.statusItem.button?.window?.frame {
            setFrame(statusItemFrame, display: false, animate: true)
        }
    }
    
}
