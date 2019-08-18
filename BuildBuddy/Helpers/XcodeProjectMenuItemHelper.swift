//
//  MenuItemManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 06/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class XcodeProjectMenuItemHelper {
    
    // MARK: - Properties
    static private var buildListController: BuildListWindowController?
    static private var alternateNamesController: AlternateNamesWindowController?
    static var menuItemsForProjects: [XcodeProjectMenuItem]  {
        // Get all the projects with builds and sort them by name
        let items = XcodeProjectManager.projectsWithBuilds.map() { project -> XcodeProjectMenuItem in
            let item = XcodeProjectMenuItem(project)
            item.title = project.name
            return item
        }
        return items.sorted() { $0.title < $1.title }
    }
    
    @objc static private func showAlternateNamesController(_ sender: XcodeProjectMenuItem) {
        NSApp.activate(ignoringOtherApps: true)
        alternateNamesController?.close()
        alternateNamesController = AlternateNamesWindowController(sender.project)
        alternateNamesController?.showWindow(nil)
    }
    
    // MARK: - Exposed Methods
    static func submenuForMenuItem(_ item: XcodeProjectMenuItem) -> NSMenu? {
        let submenu = NSMenu()
        var items = String.BuildTimePeriod.allCases.flatMap() { itemsForTimePeriod($0, project: item.project) }
        if item.project.hasAlternateNames {
            let item = changeNameItem(forProject: item.project)
            items.append(item)
        }
        if let item = derivedDataItem(forProject: item.project) {
            items.append(item)
        }
        submenu.items = items

        return submenu
    }
    
    static func changeNameItem(forProject project: XcodeProject) -> XcodeProjectMenuItem {
        let newItem = XcodeProjectMenuItem(project)
        newItem.title = "Change Name..."
        newItem.action = #selector(showAlternateNamesController(_:))
        newItem.target = self
        return newItem
    }
    
    static func derivedDataItem(forProject project: XcodeProject) -> XcodeProjectMenuItem? {
        guard let derivedDataFolderName = project.derivedDataFolderName, FileManager.folderIsValid(derivedDataFolderName) else {
            return nil
        }
        let item = XcodeProjectMenuItem(project)
        item.title = "Delete Derived Data..."
        item.action = #selector(confirmDerivedDataDeletion(_:))
        item.target = self
        return item
    }
    
    @objc static func confirmDerivedDataDeletion(_ sender: XcodeProjectMenuItem) {
        let project = sender.project
        let alert = NSAlert()
        alert.informativeText = "Are you sure you want to delete Derived Data for this project?"
        alert.messageText = "\(project.name)"
        alert.addButton(withTitle: "Okay")
        alert.addButton(withTitle: "Cancel")
        let result = alert.runModal()
        if result == .alertFirstButtonReturn {
            deleteDerivedDataForProject(sender.project)
        }
    }
    
    static func deleteDerivedDataForProject(_ project: XcodeProject) {
        let folderName = project.derivedDataFolderName ?? ""
        let url = URL(fileURLWithPath: folderName)
        let running = NSWorkspace.shared.runningApplications
        let filtered = running.filter() { $0.bundleIdentifier == "com.apple.dt.Xcode" }
        if !filtered.isEmpty {
            NSAlert.showSimpleAlert(title: "Xcode Still Running", message: "To safely delete Derived Data, please close any instances of Xcode and try again", isError: true, completionHandler: nil)
        }
        else {
            let trashed = FileManager.trashFile(url)
            if trashed {
                XcodeProjectManager.forceProjectUpdate()
                NSAlert.showSimpleAlert(title: "Success", message: "Derived Data has been deleted", completionHandler: nil)
            } else {
                NSAlert.showSimpleAlert(title: "Error", message: "Could not delete Derived Data. Please try again", isError: true, completionHandler: nil)
            }
        }
    }

    @objc static func showBuildListControllerForProject(_ sender: XcodeProjectMenuItem) {
        NSApp.activate(ignoringOtherApps: true)
        let project = sender.project
        buildListController?.close()
        guard let period = sender.period,
            let builds = project.buildsForPeriod(period) else {
                return
        }
        buildListController = BuildListWindowController(builds, period: period)
        buildListController?.showWindow(nil)
    }
    
    // MARK : - Private Methods
    static private func itemsForTimePeriod(_ period: String.BuildTimePeriod, project: XcodeProject) -> [NSMenuItem] {
        guard UserDefaults.get(period) == true else { return [] }
        let buildsForPeriod = project.buildsForPeriod(period) ?? []
        let timePeriodTitle = String.menuItemTitleFormatter(withPeriod: period, numberOfBuilds: buildsForPeriod.count)
        let periodItem = NSMenuItem(title: timePeriodTitle, action: nil, keyEquivalent: "")
        let timeItem = XcodeProjectMenuItem(project)
        let selector = buildsForPeriod.count > 0 ? #selector(showBuildListControllerForProject(_:)) : nil
        let buildTimes = buildsForPeriod.compactMap() { $0.totalBuildTime }
        let total = buildTimes.reduce(0, +)
        timeItem.title = String.formattedTime(total, forPeriod: period)
        timeItem.target = self
        timeItem.period = period
        timeItem.action = selector
        let separator = NSMenuItem.separator()
        
        return [periodItem, timeItem, separator]
    }
    
}
