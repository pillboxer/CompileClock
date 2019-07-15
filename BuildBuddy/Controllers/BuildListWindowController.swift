//
//  BuildListWindowController.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 08/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class BuildListWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: NSTableView!
    
    // MARK: - Properties
    override var windowNibName: NSNib.Name? {
        return "BuildListWindowController"
    }
    
    private var builds: [XcodeBuild]
    private let period: String.BuildTimePeriod
    lazy var dateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        return formatter
    }()
    
    // MARK: - Initialisation
    init(_ builds: [XcodeBuild], period: String.BuildTimePeriod) {
        self.builds = builds.sorted() { $0.buildDate > $1.buildDate }
        self.period = period
        super.init(window: nil)
    }
    
    func windowDidResignKey(_ notification: Notification) {
        window?.close()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.center()
        window?.title = builds.first?.name ?? "Build"
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        if let sortedBuilds = (builds as NSArray).sortedArray(using: tableView.sortDescriptors) as? [XcodeBuild] {
            self.builds = sortedBuilds
            tableView.reloadData()
        }

    }

    
    // MARK: - Table View Data Source
    func numberOfRows(in tableView: NSTableView) -> Int {
        return builds.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn else {
            return nil }
        
        let build = builds[row]
        var identifier = ""
        var text: String?
        var image: NSImage?
        
        switch tableColumn.identifier {
        case NSUserInterfaceItemIdentifier(rawValue: "DateColumn"):
            identifier = "DateView"
            text = dateFormatter.string(from: build.buildDate)
        case NSUserInterfaceItemIdentifier(rawValue: "ElapsedColumn"):
            identifier = "ElapsedView"
            let buildTime = build.totalBuildTime
            let prettyTime = String.prettyTime(buildTime)
            text = prettyTime
        case NSUserInterfaceItemIdentifier(rawValue: "SuccessColumn"):
            identifier = "SuccessView"
            image = build.wasSuccessful ? NSImage(named: "success") : NSImage(named: "failure")
        case NSUserInterfaceItemIdentifier(rawValue: "TypeColumn"):
            identifier = "TypeView"
            text = build.buildType.pretty
        default:
            return nil
        }

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(identifier), owner: nil) as? NSTableCellView {
            cell.imageView?.image = image
            cell.textField?.stringValue = text ?? ""
            return cell
        }
        return nil

    }

}
