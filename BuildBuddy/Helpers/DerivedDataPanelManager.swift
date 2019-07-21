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
            let alert = NSAlert()
            alert.messageText = "Error: Could Not Find Library Folder"
            alert.runModal()
            return
        }
        let derivedDataLocation = URL(fileURLWithPath: "\(libraryFolder)/Developer/Xcode/")
        panel.directoryURL = derivedDataLocation
        panel.begin() { response in
            if response == .cancel {
                if onInitialLaunch {
                    WelcomeManager.shared.close()
                    WelcomeManager.shared.showWelcome()
                }
                return
            }
            guard let url = panel.url, derivedDataLocationIsValid(withUrl: url) else {
                let alert = NSAlert()
                alert.messageText = "It looks like this is not a valid DerivedData location. Please check and try again"
                alert.alertStyle = .warning
                alert.beginSheetModal(for: panel)
                return
            }
            
            UserDefaults.saveDerivedDataURL(url)
            
            if onInitialLaunch {
                WelcomeManager.shared.showSuccess()
                UserDefaults.hasLaunchedBefore = true
            }
        }
    }
    
    private static func derivedDataLocationIsValid(withUrl url: URL) -> Bool {
        let fileManager = FileManager.default
        
        if !url.path.contains("DerivedData") {
            return false
        }
        
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.nameKey, .isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants], errorHandler: nil) else {
            return false
        }
        let names = enumerator.map() { $0 as! URL }
        return names.contains() { $0.path.contains("ModuleCache") }
    }
    
}
