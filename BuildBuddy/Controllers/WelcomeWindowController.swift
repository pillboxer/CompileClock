//
//  WelcomeWindowController.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 20/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class WelcomeWindowController: NSWindowController {

    // MARK: - Action Methods
    @IBAction func openPanel(_ sender: Any) {
        DerivedDataPanelManager.showDerivedDataPanel(onInitialLaunch: true)
        window?.close()
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var firstBodyLabel: NSTextField!
    @IBOutlet weak var secondBodyLabel: NSTextField!
    @IBOutlet weak var arrowImageView: NSImageView!
    @IBOutlet weak var letsGoButton: NSButton!
    
    // MARK: - Properties
    enum DisplayState {
        case welcome
        case getStarted
    }
    private let state: DisplayState
    override var windowNibName: NSNib.Name? {
        return "WelcomeWindowController"
    }
    
    // MARK: - Life Cycle
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.styleMask.remove([.closable, .resizable])
        window?.center()
        configureUIForState()
    }


    // MARK: - Initialisation
    init(displayState: DisplayState) {
        state = displayState
        super.init(window: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK : - Private Methods
    private func configureUIForState() {
        switch state {
        case .welcome:
            firstBodyLabel.stringValue = "BuildBuddy helps you keep track of the time you spend compiling your software."
            secondBodyLabel.stringValue = "To get started, confirm the location of your Derived Data folder"
            letsGoButton.isHidden = false
            arrowImageView.isHidden = true
        case .getStarted:
            firstBodyLabel.stringValue = "You're All Set Up And Ready To Go."
            secondBodyLabel.stringValue = "Check Your Builds By Opening The Menu Bar App Above"
            letsGoButton.isHidden = true
            arrowImageView.isHidden = false
        }
    }
    
}
