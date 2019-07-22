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
    static private var controller: BuildListWindowController?
    static var menuItemsForProjects: [XcodeProjectMenuItem]  {
        // Get all the projects with builds and sort them by name
        let items = XcodeProjectManager.projectsWithBuilds.map() { project -> XcodeProjectMenuItem in
            let item = XcodeProjectMenuItem(project)
            item.title = project.name
            return item
        }
        return items.sorted() { $0.title < $1.title }
    }
    
    // MARK: - Exposed MEthods
    static func submenuForMenuItem(_ item: XcodeProjectMenuItem) -> NSMenu? {
        let submenu = NSMenu()
        let items = String.BuildTimePeriod.allCases.flatMap() { itemsForTimePeriod($0, project: item.project) }
        submenu.items = items

        return submenu
    }

    @objc static func showBuildListControllerForProject(_ sender: XcodeProjectMenuItem) {
        NSApp.activate(ignoringOtherApps: true)
        let project = sender.project
        controller?.close()
        guard let period = sender.period,
            let builds = project.buildsForPeriod(period) else {
                return
        }
        controller = BuildListWindowController(builds, period: period)
        controller?.showWindow(nil)
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
