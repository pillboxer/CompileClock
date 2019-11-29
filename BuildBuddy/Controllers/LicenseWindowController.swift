//
//  LicenseWindowController.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 29/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class LicenseWindowController: NSWindowController {
    
    @IBOutlet weak var buyButton: NSButton!
    @IBOutlet var licenseViewController: LicenseViewController!
    
    static let nibName = "LicenseWindowController"
    
    public convenience init() {
        
        self.init(windowNibName: LicenseWindowController.nibName)
    }
    
    
}
