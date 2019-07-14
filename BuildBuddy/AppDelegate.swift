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
    var menu = NSMenu()
    var lastMenuItems = [NSMenuItem]()
    let preferences = NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: "")
    
    var projects = XcodeProjectManager.projects
    var defaultsHaveChanged = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerDefaults()
        let image = NSImage(named: "hammer")
        image?.size = NSMakeSize(18.0, 18.0)
        statusItem.button?.image = image
        menu.delegate = self
        statusItem.menu = menu
        lastMenuItems = [preferences]
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    private func registerDefaults() {
        if !UserDefaults.hasLaunchedBefore {
            UserDefaults.setInitialDefaults()
        }

    }

    private func constructMenu() {
        menu.items = XcodeProjectMenuItemHelper.menuItemsForProjects(projects)
        constructSubmenus()
        let separator = NSMenuItem.separator()
        menu.addItem(separator)
        if UserDefaults.allPeriodsDisabled {
            menu.items.forEach() { $0.isHidden = true }
        }
        menu.addItem(preferences)
        lastMenuItems = menu.items
    }

    private func constructSubmenus() {
        menu.items.forEach() { item in
            if let item = item as? XcodeProjectMenuItem, item.title != "" {
                let submenu = XcodeProjectMenuItemHelper.submenuForMenuItem(item)
                menu.setSubmenu(submenu, for: item)
            }
        }
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        loadMenu()
    }
    
    private func showLoadingItem() {
        let item = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        let controller = FetchingMenuItemViewController()
        item.view = controller.view
        menu.items = [item]
    }
    
    @objc func openPreferences() {
        PreferencesManager.shared.showPreferences()
    }
    
    private func loadMenu() {
        // If we don't have new builds, just show the last ones
        guard XcodeProjectManager.needsUpdating else {
            print("No need")
            menu.items = lastMenuItems
            return
        }
        // We have new builds, so show the loading indicator and reset the defaults
        showLoadingItem()
        Listener.shared.resetDefaults()
        
        // fetch the builds and once that's done construct the menu (all the while we are showing the indicator)
        fetchProjects()
        DispatchQueue.main.async {
            self.constructMenu()
        }
    }
    
    private func fetchProjects() {
        for project in projects {
            project.fetchBuilds()
        }
    }
    
    
}

