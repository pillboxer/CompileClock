//
//  DerivedDataPanelManager.swift
//  CompileClock
//
//  Created by Henry Cooper on 20/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class DerivedDataPanelManager {
    
    static var panel = NSOpenPanel()
    
    // MARK: - Exposed Methods
    static func showDerivedDataPanel(onInitialLaunch: Bool) {
        // Configure the panel
        panel.close()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        
        // Make sure we can find library folder
        guard let xcodeFolder = FileManager.standardXcodeFolder else {
            let alert = NSAlert()
            alert.messageText = "Error: Could Not Find Library Folder"
            alert.runModal()
            return
        }
        
        // Set the panel to the standard derivedData location
        let derivedDataLocation = UserDefaults.derivedDataURL
        panel.directoryURL = derivedDataLocation
        
        panel.begin() { response in
            // If it's the initial launch, reshow the welcome screen on cancel
            if response == .cancel {
                if onInitialLaunch {
                    WelcomeManager.shared.close()
                    WelcomeManager.shared.showWelcome()
                }
                return
            }
            guard let url = panel.url else {
                return
            }
            
//            if !derivedDataLocationIsValid(withUrl: url) {
//                let alert = NSAlert()
//                alert.messageText = "It looks like this is not a valid DerivedData location. Please check and try again"
//                alert.alertStyle = .warning
//                // I hate this, but we seem to lose control of the panel once ok is clicked on the modal, so we need to create a new one
//                alert.beginSheetModal(for: panel) { _ in
//                    showDerivedDataPanel(onInitialLaunch: onInitialLaunch)
//                }
//                return
//            }
            
            UserDefaults.saveDerivedDataURL(url)
            
            if onInitialLaunch {
                NSAlert.showSimpleAlert(title: "DerivedData Location Changed", message: "If your DerivedData location changes in the future, you can update CompileClock in the Advanced tab in Preferences") {
                    WelcomeManager.shared.showSuccess()
                }
                UserDefaults.hasLaunchedBefore = true
            }
        }
    }
    
    static func derivedDataLocationIsValid(withUrl url: URL) -> Bool {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.nameKey, .isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants], errorHandler: nil) else {
            return false
        }
        let names = Set(enumerator.map() { $0 as! URL })
        return names.contains() { $0.path.contains("ModuleCache") }
    }
    
}
