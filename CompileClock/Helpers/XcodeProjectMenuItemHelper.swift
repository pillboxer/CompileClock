//
//  MenuItemManager.swift
//  CompileClock
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
        let items = XcodeProjectManager.visibleProjects.map() { project -> XcodeProjectMenuItem in
                let item = XcodeProjectMenuItem(project)
                item.title = project.name
                return item
        }
        return items.sorted() { $0.title.lowercased() < $1.title.lowercased() }
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
        if let derivedDataItem = derivedDataItem(forProject: item.project){
            items.append(derivedDataItem)
        }
        items.append(resetItem(forProject: item.project))
        submenu.items = items

        return submenu
    }
    
    static private func resetItem(forProject project: XcodeProject) -> XcodeProjectMenuItem {
        let item = XcodeProjectMenuItem(project)
        item.title = "Reset Project..."
        item.action = #selector(resetProjectData(_:))
        item.target = self
        return item
    }
    
    static private func changeNameItem(forProject project: XcodeProject) -> XcodeProjectMenuItem {
        let newItem = XcodeProjectMenuItem(project)
        newItem.title = "Change Name..."
        newItem.action = #selector(showAlternateNamesController(_:))
        newItem.target = self
        return newItem
    }
    
    static private func derivedDataItem(forProject project: XcodeProject) -> XcodeProjectMenuItem? {
        guard let derivedDataFolderName = project.derivedDataFolderName, FileManager.folderIsValid(derivedDataFolderName) else {
            return nil
        }
        let item = XcodeProjectMenuItem(project)
        item.title = "Delete Derived Data..."
        item.action = #selector(confirmDerivedDataDeletion(_:))
        item.target = self
        return item
    }
    

    
    @objc private static func confirmDerivedDataDeletion(_ sender: XcodeProjectMenuItem) {
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
    
    static func deleteDerivedDataForProject(_ project: XcodeProject, forceDelete: Bool = false) {
        let folderName = project.derivedDataFolderName ?? ""
        let url = URL(fileURLWithPath: folderName)
        
        if forceDelete {
            FileManager.trashFile(url)
            return
        }
        
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
    
    @objc static private func resetProjectData(_ sender: XcodeProjectMenuItem) {
        let project = sender.project
        let alert = NSAlert()
        alert.informativeText = "This will delete any existing data CompileClock has for \(project.name). The latest information for the project will then be fetched from your Derived Data folder.\n\nIf you'd rather just hide the project, you can do so in Preferences."
        alert.messageText = "Reset data for \(project.name)?"
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Cancel")
        let result = alert.runModal()
        if result == .alertFirstButtonReturn {
            APIManager.shared.deleteProject(project) { (error) in
                if let error = error {
                    NSAlert.showSimpleAlert(title: "Error", message: "Could Not Delete Project On Backend: \(error.localizedDescription)", isError: true, completionHandler: nil)
                }
                else {
                    DispatchQueue.main.async {
                        CoreDataManager.moc.delete(project)
                        CoreDataManager.saveOnMainThread()
                        XcodeProjectManager.forceProjectUpdate()
                    }
                }
            }
        }
    }

    @objc static private func showBuildListControllerForProject(_ sender: XcodeProjectMenuItem) {
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
