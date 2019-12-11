//
//  WelcomeWindowController.swift
//  CompileClock
//
//  Created by Henry Cooper on 20/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class WelcomeWindowController: NSWindowController {
    
    // MARK: - Action Methods
    @IBAction func openPanel(_ sender: Any) {
        if let frame = window?.frame {
            let newFrame = NSRect(x: frame.minX, y: frame.minY, width: 0, height: 0)
            NSAnimationContext.runAnimationGroup({ _ in
                NSAnimationContext.current.duration = 0.2
                window?.animator().setFrame(newFrame, display: true, animate: true)
            }) {
                DerivedDataPanelManager.showDerivedDataPanel(onInitialLaunch: true)
                self.window?.close()
            }
        }


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
        window?.styleMask.remove([.resizable])
        window?.title = "CompileClock"
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
            firstBodyLabel.stringValue = "CompileClock helps you keep track of the time you spend compiling your software."
            secondBodyLabel.stringValue = "To get started, click 'Let's Go' and select your 'DerivedData' folder."
            letsGoButton.isHidden = false
            arrowImageView.isHidden = true
            
        case .getStarted:
            firstBodyLabel.stringValue = "You're all set up and ready to go."
            secondBodyLabel.stringValue = "Check your builds by selecting the menu bar icon"
            letsGoButton.isHidden = true
            arrowImageView.isHidden = false
        }
        if let frame = window?.frame {
            window?.setContentSize(NSSize.zero)
            NSAnimationContext.runAnimationGroup() { _ in
                NSAnimationContext.current.duration = 0.2
                window?.animator().setFrame(frame, display: true, animate: true)
            }
        }
    }
    
}
