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
    #warning("Change This At Some Point")
    let preferences = NSMenuItem(title: "Preferences", action: #selector(openPreferences), keyEquivalent: "")
    let stats = NSMenuItem(title: "Stats", action: #selector(openStats), keyEquivalent: "")
    let quit = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "")
    #warning("Change this")

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        quit.keyEquivalentModifierMask = .command
        quit.keyEquivalent = "q"
        registerDefaults()
        configureStatusItem()
        menu.delegate = self
        lastMenuItems = launchingMenuItems
        loadMenu()
    }

    lazy var launchingMenuItems: [NSMenuItem] = {
       return [preferences, NSMenuItem.separator(), quit]
    }()
    
    private func configureStatusItem() {
        let image = NSImage(named: "hammer")
        image?.size = NSMakeSize(18.0, 18.0)
        statusItem.button?.image = image
        statusItem.menu = menu
    }
    
    private func registerDefaults() {
        if !UserDefaults.hasLaunchedBefore {
            UserDefaults.setInitialDefaults()
            WelcomeManager.shared.showWelcome()
            return
        }
        
    }

    private func constructMenu() {
        let items = XcodeProjectMenuItemHelper.menuItemsForProjects(XcodeProjectManager.projects)
        menu.items = items
        constructSubmenus()
        if UserDefaults.allPeriodsDisabled {
            menu.items.forEach() { $0.isHidden = true }
        }
        if items.count > 0 {
            menu.addItem(NSMenuItem.separator())
            menu.addItem(stats)
        }
        menu.addItem(preferences)
        menu.addItem(quit)
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
        WelcomeManager.shared.close()
        guard UserDefaults.derivedDataURL != nil else {
            let item = NSMenuItem(title: "Set Derived Data Location...", action: #selector(openPanel), keyEquivalent: "")
            menu.items = [item]
            return
        }
        
        // If we don't have new builds, just show the last ones
        guard XcodeProjectManager.needsUpdating else {
            menu.items = lastMenuItems
            return
        }
        // we have new builds so load the menu
        loadMenu()
    }
    
    private func showLoadingItem() {
        let item = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        let controller = FetchingMenuItemViewController()
        item.view = controller.view
        menu.items = [item]
    }
    
    @objc func openPreferences() {
        PreferencesManager.showPreferences()
    }
    
    @objc func openStats() {
        StatsManager.shared.showStats()
    }
    
    private func loadMenu() {
        showLoadingItem()
        Listener.shared.resetDefaults()
        fetchProjects()
        DispatchQueue.main.async {
            self.constructMenu()
        }
    }
    
    private func fetchProjects() {
        for project in XcodeProjectManager.projects {
            project.fetchBuilds()
        }
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    @objc private func openPanel() {
        DerivedDataPanelManager.showDerivedDataPanel(onInitialLaunch: !UserDefaults.hasLaunchedBefore)
    }
    
}

