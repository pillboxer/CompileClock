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
            let targetFrame = NSRect(x: statusItemFrame.origin.x, y: statusItemFrame.origin.y, width: 0, height: 0)
            setFrame(targetFrame, display: false, animate: true)
        }
    }
    
}
