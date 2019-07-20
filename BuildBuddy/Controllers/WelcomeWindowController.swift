//
//  WelcomeWindowController.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 20/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class WelcomeWindowController: NSWindowController {

    @IBAction func openPanel(_ sender: Any) {
        DerivedDataPanelManager.showDerivedDataPanel(onInitialLaunch: true)
        window?.close()
    }
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.styleMask.remove([.closable, .resizable])
        window?.center()
    }
    
    deinit {
        print("gone")
    }
    
    override var windowNibName: NSNib.Name? {
        return "WelcomeWindowController"
    }
    
    init() {
        super.init(window: nil)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
