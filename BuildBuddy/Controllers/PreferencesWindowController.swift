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
    @IBOutlet weak var projectsContainerView: NSView!
    @IBOutlet weak var advancedContainerView: NSView!
    
    // MARK: - Controllers
    let menuPreferencesController = MenuPreferencesViewController()
    let advancedPreferencesController = AdvancedPreferencesViewController()
    let projectsPreferencesController = ProjectPreferencesViewController()
    
    // MARK: - Properties
    override var windowNibName: NSNib.Name? {
        return "PreferencesWindowController"
    }
    
    // MARK: - Initialisation
    init() {
        super.init(window: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func windowDidLoad() {
        super.windowDidLoad()
        addToContainerView()
        window?.title = "Preferences"
        window?.styleMask.remove(.resizable)
    }
    
    // MARK : - Private Methods
    private func addToContainerView() {
        menuContainerView.addSubview(menuPreferencesController.view)
        menuPreferencesController.view.frame = menuContainerView.bounds
        advancedContainerView.addSubview(advancedPreferencesController.view)
        advancedPreferencesController.view.frame = advancedContainerView.bounds
        projectsContainerView.addSubview(projectsPreferencesController.view)
        projectsPreferencesController.view.frame = projectsContainerView.bounds
    }
}
