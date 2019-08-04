//
//  AlternateNamesWindowController.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 03/08/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class AlternateNamesWindowController: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var popUpButton: NSPopUpButton!
    // MARK: - Properties
    override var windowNibName: NSNib.Name? {
        return "AlternateNamesWindowController"
    }
    
    private var project: XcodeProject

    // MARK: - Initialisation
    init(_ project: XcodeProject) {
        self.project = project
        super.init(window: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func windowWillClose(_ notification: Notification) {
        let currentName = popUpButton.selectedItem?.title ?? project.name
        project.name = currentName
    }
    
    // MARK: - Life Cycle
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.styleMask.remove(.resizable)
        window?.title = "Change Name"
        configurePopUp()
    }
    
    // MARK : - Private Methods
    private func configurePopUp() {
        let alternatives = project.nameAlternatives.sorted()
        alternatives.forEach() { popUpButton.addItem(withTitle: $0) }
        popUpButton.selectItem(withTitle: project.name)
    }
    
}
