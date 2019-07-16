//
//  StatsWindowController.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 15/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class StatsWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {
        return "StatsWindowController"
    }
    
    @IBOutlet weak var statsContainerView: NSView!
    @IBOutlet weak var outlineView: NSOutlineView!
    let projects: [XcodeProject]
    let statsViewController = StatsViewController()
    
    init(projects: [XcodeProject]) {
        self.projects = projects
        super.init(window: nil)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        outlineView.dataSource = self
        outlineView.delegate = self
        statsContainerView.addSubview(statsViewController.view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension StatsWindowController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return projects.count + 1
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if index == 0 {
            return "PROJECTS"
        }
        return projects[index - 1]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        print(item)
        
        if item as? String == "PROJECTS" {
            if let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("HeaderCell"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = "PROJECTS"
                return cell
            }
        }

        if let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DataCell"), owner: nil) as? NSTableCellView, let item = item as? XcodeProject, let name = item.name {
            cell.textField?.stringValue = name
            return cell
        }
        return nil
    }

    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if item as? String == "PROJECTS" {
            return false
        }
        return true
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let row = outlineView.selectedRow
        statsViewController.loadWithProject(projects[row - 1])
    }
    
}
