//
//  AppDelegate.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 04/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let menu = NSMenu()
    var projects = [XcodeProject]()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerDefaults()
        let image = NSImage(named: "hammer")
        image?.size = NSMakeSize(18.0, 18.0)
        statusItem.button?.image = image
        ValueTransformer.setValueTransformer(IsAutomaticValueTransformer(), forName: IsAutomaticValueTransformer.name)
        constructMenu()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    private func registerDefaults() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        if !UserDefaults.hasLaunchedBefore {
            UserDefaults.setInitialDefaults()
        }
    }

    private func constructMenu() {
        menu.delegate = self
        statusItem.menu = menu
        menu.items = XcodeProjectMenuItemHelper.menuItemsForProjects(projects)
        constructSubmenus()
        let separator = NSMenuItem.separator()
        menu.addItem(separator)
        if UserDefaults.allPeriodsDisabled {
            menu.items.forEach() { $0.isHidden = true }
        }
        constructPreferences()
    }
    
    private func constructPreferences() {
        let preferences = NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: "")
        menu.addItem(preferences)
    }

    
    private func constructSubmenus() {
        let date = Date().timeIntervalSinceReferenceDate

        menu.items.forEach() { item in
            if let item = item as? XcodeProjectMenuItem, item.title != "" {
                let submenu = XcodeProjectMenuItemHelper.submenuForMenuItem(item)
                menu.setSubmenu(submenu, for: item)
            }
        }
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        fetchProjects()
        constructMenu()
    }
    
    @objc func openPreferences() {
        PreferencesManager.shared.showPreferences()
    }
    
    private func fetchProjects() {
        projects = XcodeProjectManager.projects
        for project in XcodeProjectManager.projects {
            project.fetchBuilds()
        }
    }
    
    
}

