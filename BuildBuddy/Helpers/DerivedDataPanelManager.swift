//
//  DerivedDataPanelManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 20/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class DerivedDataPanelManager {
    
    static func showDerivedDataPanel(onInitialLaunch: Bool) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        guard let libraryFolder = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            return
        }
        panel.title = "Derived Data Location"
        panel.message = "Confirm The Location Of Your Derived Data"
        let derivedDataLocation = URL(fileURLWithPath: "\(libraryFolder)/Developer/Xcode/")
        panel.directoryURL = derivedDataLocation
        panel.begin() { response in
            if response == .cancel {
                if onInitialLaunch {
                    WelcomeManager.shared.showWelcome()
                }
                return
            }
            if let url = panel.url {
                UserDefaults.saveDerivedDataURL(url)
            }
            
            if onInitialLaunch {
                // Show get started controller
                UserDefaults.hasLaunchedBefore = true
            }
        }
    }
    
}
