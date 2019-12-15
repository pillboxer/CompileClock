//
//  LicenseWindowController.swift
//  CompileClock
//
//  Created by Henry Cooper on 29/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class LicenseWindowController: NSWindowController {
    
    @IBOutlet var licenseViewController: LicenseViewController!
    
    override var windowNibName: NSNib.Name? {
        return "LicenseWindowController"
    }
    public convenience init() {
        self.init(window: nil)
    }
    
    override func windowDidLoad() {
        window?.styleMask.remove([.resizable])
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        window?.title = "CompileClock"
        window?.delegate = licenseViewController
        licenseViewController.validateTextFields()
    }
    
    var registrationHandler: HandlesRegistering? {
        
        get {
            return licenseViewController.eventHandler
        }
        set {
            licenseViewController.eventHandler = newValue
        }
    }
    
    func displayLicensing(_ licensing: Licensing) {
        switch licensing {
        case .unregistered:
            // Show whatever the user left on the screen
            break
        case .registered(let license):
            licenseViewController.displayLicenseInformation(license)
        }
    }
    
    
}
