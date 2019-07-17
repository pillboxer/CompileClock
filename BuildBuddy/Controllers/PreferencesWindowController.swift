//
//  PreferencesWindowController.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 09/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa
import AppKit

class PreferencesWindowController: NSWindowController, NSWindowDelegate {

    // MARK: - IBOutlets
    
    @IBOutlet weak var menuContainerView: NSView!
    @IBOutlet weak var tabView: NSTabView!
    
    // MARK: - Controllers
    let menuPreferencesController = MenuPreferencesViewController()
    
    // MARK: - Properties
    override var windowNibName: NSNib.Name? {
        return "PreferencesWindowController"
    }
    
    init() {
        super.init(window: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        addToContainerView()
        window?.title = "Preferences"
        window?.styleMask.remove(.resizable)
    }
    
    private func addToContainerView() {
        menuContainerView.addSubview(menuPreferencesController.view)
        menuPreferencesController.view.frame = menuContainerView.bounds
    }
}
