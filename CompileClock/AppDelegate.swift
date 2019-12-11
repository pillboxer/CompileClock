//
//  AppDelegate.swift
//  CompileClock
//
//  Created by Henry Cooper on 04/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    static let shared = AppDelegate()
    
    // MARK: - Properties
    var statusItem = NSStatusBar.system.statusItem(withLength: 15.0)
    let listener = Listener.shared
    var menu = NSMenu()
    var lastMenuItems = [NSMenuItem]()
    var lastFetchDate = Date()
    let semaphore = DispatchSemaphore(value: 1)
    let licenseWindowController = LicenseWindowController()
    let licensingProvider = LicensingProvider()
    
    private var currentLicensing: Licensing {
        return licensingProvider.licensing
    }

    private var hasFetchedToday: Bool {
        let date = Date()
        return Calendar.numberOfDaysBetweenDates(date, lastFetchDate) == 0
    }
    
    private var needsUpdating: Bool {
        return XcodeProjectManager.needsUpdating || listener.defaultsChanged || !hasFetchedToday
    }
    
    private var licensingIsValid: Bool {
        switch currentLicensing {
        case .unregistered:
            return false
        case .registered:
            return true
        }
    }
    
    // MARK: - Menu Items
    let preferences = NSMenuItem(title: "Preferences", action: #selector(openPreferences), keyEquivalent: "")
    let help = NSMenuItem(title: "Help", action: #selector(openHelp), keyEquivalent: "")
    let stats = NSMenuItem(title: "Stats", action: #selector(openStats), keyEquivalent: "")
    let licensingInformation = NSMenuItem(title: "License", action: #selector(registerApplication), keyEquivalent: "")
    let about = NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: "")
    let checkForUpdatesItem = NSMenuItem(title: "Check For Updates", action: #selector(checkForUpdates), keyEquivalent: "")
    
    let quit: NSMenuItem = {
        let quit = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quit.keyEquivalentModifierMask = .command
        return quit
    }()
    
    
    
    lazy var launchingMenuItems: [NSMenuItem] = {
        return [preferences, NSMenuItem.separator(), help, NSMenuItem.separator(), about, quit]
    }()
    
    lazy var unregisteredMenuItems: [NSMenuItem] = {
        return [licensingInformation, about, quit]
    }()
    
    
    // MARK: - Life Cycle
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.appearance = NSAppearance(named: .aqua)
        observeLicenseChanges()
        launchAppOrShowLicensingInformation()
    }
    
    private func launchAppOrShowLicensingInformation() {
        licensingIsValid ? unlockApp() : registerApplication()
    }
    
    private func beginPostLaunchSequence() {
        LogUtility.updateLogWithEvent(.appLaunched)
        XcodeProjectManager.start()
        DatabaseManager.shared.startPostLaunchUserFlow { (success) in
            LogUtility.updateLogWithEvent(.databasePostLaunchOperationCompleted(success))
        }
    }
    
    // MARK: - Menu Bar Icon
    private func configureStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let image = NSImage(named: "hammer")
        image?.size = NSMakeSize(17.0, 17.0)
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
    private func reloadMenuIfNecessary() {
        if !licensingIsValid {
            lockApp()
            return
        }
        XcodeProjectManager.retrieveNewProjects()
        // If there's no derivedDataURL, we need to set it. Just show that option and quit
        guard let _ = UserDefaults.derivedDataURL else {
            let item = NSMenuItem(title: "Set Derived Data Location...", action: #selector(openPanel), keyEquivalent: "")
            LogUtility.updateLogWithEvent(.derivedDataIsValid(false))
            item.image = NSImage(named: "failure")
            item.image?.size = NSSize(width: 18, height: 18)
            menu.items = [item, help, about, quit]
            return
        }
        
        // If the projects have been updated, or we have changed stuff in preferences, we should update.
        // Otherwise, just show the last items we were showing
        guard needsUpdating else {
            menu.items = lastMenuItems
            return
        }
        
        // we have new builds so load the menu
        LogUtility.updateLogWithEvent(.needsFetch(true))
        loadMenu()
    }
    
    private func loadMenu() {
        // Show the spinner
        showLoadingItem()
        // Put the defaultsChanged status back to false so we don't fetch unnecessarily
        Listener.shared.resetDefaultsChangedStatus()
        // Fetch the projects
        // Do this asynchronously, otherwise the menu bar won't open whilst it is constructing
        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()
            self.fetchBuilds()
            DispatchQueue.main.async {
                self.semaphore.signal()
                self.constructMenu()
                DatabaseManager.shared.updateProjects { _ in
                    DispatchQueue.main.async {
                        CoreDataManager.saveOnMainThread()
                    }
                }
            }
        }
    }
    
    private func startFetchLoop() {
        reloadMenuIfNecessary()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 120.0) {
            self.startFetchLoop()
        }
    }
    
    private func showLoadingItem() {
        // Sets the animated loading menu itme
        menu.items = [FetchingMenuItemManager.menuItem]
    }
    
    private func fetchBuilds() {
        LogUtility.updateLogWithEvent(.startingFetch(hasFetchedToday))
        FetchingMenuItemManager.start()
        XcodeProjectManager.fetchBuilds()
        FetchingMenuItemManager.finish()
        lastFetchDate = Date()
        XcodeProjectManager.mergeProjectsIfNecessary()
        LogUtility.updateLogWithEvent(.fetchComplete)
    }
    
    private func constructMenu() {
        loadDisplayText()
        FetchingMenuItemManager.resetView()
        let items = XcodeProjectMenuItemHelper.menuItemsForProjects
        menu.items = items
        constructSubmenus()
        
        if UserDefaults.allPeriodsDisabled {
            menu.items.forEach() { item in
                // Create the menu item here otherwise you get error of "Menu Item is already in other menu"
                let nothingToShow = NSMenuItem(title: "Nothing To Show", action: nil, keyEquivalent: "")
                item.submenu?.items = [nothingToShow]
            }
        }
        // Show the stats item if we have projects to show
        if items.count > 0 {
            menu.addItem(NSMenuItem.separator())
            menu.addItem(stats)
        }
        
        menu.addItem(preferences)
        menu.addItem(help)
        menu.addItem(checkForUpdatesItem)
        menu.addItem(about)
        menu.addItem(quit)
        
        // Important! This means we have items to show if we don't need to fetch and reconstruct the menu
        lastMenuItems = menu.items
    }
    
    func loadDisplayText() {
        if UserDefaults.showsDisplayText && XcodeProjectManager.hasBuiltToday {
            statusItem.button?.title = XcodeProjectManager.displayText
            statusItem.button?.imagePosition = .imageLeft
            
        } else {
            statusItem.button?.imagePosition = .imageOnly
        }
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
        
        if FetchingMenuItemManager.isFetching {
            showLoadingItem()
            return
        }
        reloadMenuIfNecessary()
    }
    
    // MARK: - Registration
    private func lockApp() {
        configureStatusItem()
        menu.items = unregisteredMenuItems
    }
    
    private func unlockApp() {
        licenseWindowController.close()
        beginPostLaunchSequence()
        registerDefaults()
        configureStatusItem()
        menu.delegate = self
        lastMenuItems = self.launchingMenuItems
        loadMenu()
        startFetchLoop()
    }
    
    private func observeLicenseChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(licenseDidChange(_:)), name: Licensing.licenseChangedNotification, object: nil)
    }
    
    // MARK: - Selectors
    @objc func openPreferences() {
        PreferencesManager.shared.showPreferences()
    }
    
    @objc func openStats() {
        StatsManager.shared.showStats()
    }
    
    @objc func openHelp() {
        HelpManager.shared.showHelpController()
    }
    
    @objc func showAbout() {
        NSApplication.shared.orderFrontStandardAboutPanel(self)
    }
    
    @objc func checkForUpdates() {
        let updater = SUUpdater()
        updater.checkForUpdates(self)
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    @objc private func openPanel() {
        DerivedDataPanelManager.showDerivedDataPanel(onInitialLaunch: !UserDefaults.hasLaunchedBefore)
    }
    
    @objc private func registerApplication() {
        lockApp()
        licenseWindowController.close()
        licenseWindowController.showWindow(nil)
        let registerService = RegisterService()
        licenseWindowController.registrationHandler = registerService
        licenseWindowController.displayLicensing(currentLicensing)
    }
    
    @objc private func licenseDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let licensing = Licensing.licensingFromUserInfo(userInfo) else {
                return
        }
        
        switch licensing {
        case .unregistered:
            lockApp()
        case .registered:
            NSAlert.showSimpleAlert(title: "Thanks!", message: "Purchase Successful. Enjoy CompileClock!") {
                self.unlockApp()
            }
        }
    }
    
}

