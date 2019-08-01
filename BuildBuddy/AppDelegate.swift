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
    
    
    static let shared = AppDelegate()
    
    // MARK: - Properties
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let listener = Listener.shared
    var menu = NSMenu()
    var lastMenuItems = [NSMenuItem]()
    var lastFetchDate = Date()
    
    private var hasFetchedToday: Bool {
        let date = Date()
        return Calendar.numberOfDaysBetweenDates(date, lastFetchDate) == 0
    }
    
    
    // MARK: - Menu Items
    let preferences = NSMenuItem(title: "Preferences", action: #selector(openPreferences), keyEquivalent: "")
    let stats = NSMenuItem(title: "Stats", action: #selector(openStats), keyEquivalent: "")
    let nothingToShow = NSMenuItem(title: "Nothing To Show", action: nil, keyEquivalent: "")
    let quit: NSMenuItem = {
        let quit = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quit.keyEquivalentModifierMask = .command
        return quit
    }()
    lazy var launchingMenuItems: [NSMenuItem] = {
        return [preferences, NSMenuItem.separator(), quit]
    }()
    
    
    // MARK: - Life Cycle
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerDefaults()
        configureStatusItem()
        menu.delegate = self
        lastMenuItems = launchingMenuItems
        startLoop()
    }
    
    // MARK: - Menu Bar Icon
    private func configureStatusItem() {
        let image = NSImage(named: "hammer")
        image?.size = NSMakeSize(18.0, 18.0)
        statusItem.button?.image = image
        statusItem.menu = menu
    }
    
    // MARK: - User Defaults
    private func registerDefaults() {
        if !UserDefaults.hasLaunchedBefore {
            UserDefaults.setInitialDefaults()
            WelcomeManager.shared.showWelcome()
            return
        }
    }
    
    // MARK: - Menu
    private func loadMenu() {
        // Show the spinner
        showLoadingItem()
        // Put the defaultsChanged status back to false so we don't fetch unnecessarily
        Listener.shared.resetDefaultsChangedStatus()
        // Fetch the projects
        // Do this asynchronously, otherwise the menu bar won't open whilst it is constructing
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchProjects()
            DispatchQueue.main.async {
                self.constructMenu()
            }
        }
    }
    
    private func constructMenu() {
        FetchingMenuItemManager.resetView()
        let items = XcodeProjectMenuItemHelper.menuItemsForProjects
        menu.items = items
        constructSubmenus()
        
        if UserDefaults.allPeriodsDisabled {
            menu.items.forEach() { item in
                item.submenu?.items = [nothingToShow]
            }
        }
        // Show the stats item if we have projects to show
        if items.count > 0 {
            menu.addItem(NSMenuItem.separator())
            menu.addItem(stats)
        }
        
        // Always add preferences and quit
        menu.addItem(preferences)
        menu.addItem(quit)
        
        // Important! This means we have items to show if we don't need to fetch and reconstruct the menu
        lastMenuItems = menu.items
    }
    
    private func constructSubmenus() {
        // If the item is an XcodeProject, add the submenu that shows our data
        menu.items.forEach() { item in
            if let item = item as? XcodeProjectMenuItem {
                let submenu = XcodeProjectMenuItemHelper.submenuForMenuItem(item)
                menu.setSubmenu(submenu, for: item)
            }
        }
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        // Close the welcome window if it's open
        WelcomeManager.shared.close()
        checkAndLoadMenu()
    }
    
    private func showLoadingItem() {
        // Sets the animated loading menu itme
        menu.items = [FetchingMenuItemManager.menuItem]
    }
    
    private func checkAndLoadMenu() {
        if FetchingMenuItemManager.isFetching {
            FetchingMenuItemManager.changeTextIfAppropriate()
            showLoadingItem()
            return
        }
        
        
        // If there's no derivedDataURL, we need to set it. Just show that option and quit
        guard let url = UserDefaults.derivedDataURL, DerivedDataPanelManager.derivedDataLocationIsValid(withUrl: url) else {
            let item = NSMenuItem(title: "Set Derived Data Location...", action: #selector(openPanel), keyEquivalent: "")
            item.image = NSImage(named: "failure")
            item.image?.size = NSSize(width: 18, height: 18)
            menu.items = [item, quit]
            return
        }
        
        // If the projects have been updated, or we have changed stuff in preferences, we should update.
        // Otherwise, just show the last items we were showing
        guard XcodeProjectManager.needsUpdating || listener.defaultsChanged || !hasFetchedToday  else {
            menu.items = lastMenuItems
            return
        }
        
        // we have new builds so load the menu
        loadMenu()
    }
    
    private func startLoop() {
        checkAndLoadMenu()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 75) { [weak self] in
            self?.startLoop()
        }
    }
    
    
    private func fetchProjects() {
        FetchingMenuItemManager.start()
        for project in XcodeProjectManager.projects {
            project.fetchBuilds()
        }
        FetchingMenuItemManager.finish()
        XcodeProjectManager.mergeProjectsIfNecessary()
        lastFetchDate = Date()
    }
    
    
    // MARK: - Selectors
    @objc func openPreferences() {
        PreferencesManager.shared.showPreferences()
    }
    
    @objc func openStats() {
        StatsManager.shared.showStats()
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    @objc private func openPanel() {
        DerivedDataPanelManager.showDerivedDataPanel(onInitialLaunch: !UserDefaults.hasLaunchedBefore)
    }
    
}

