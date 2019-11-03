//
//  ProjectPreferencesViewController.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 23/08/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class ProjectPreferencesViewController: NSViewController {

    @IBOutlet weak var stackView: NSStackView!
    @IBOutlet weak var scrollView: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addProjectCheckboxes()
        scrollView.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.1)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        CoreDataManager.save()
    }
    
    private func addProjectCheckboxes() {
        
        let sorted: [XcodeProject] = XcodeProjectManager.projectsWithBuilds.sorted { proj1, proj2 in
            if proj1.isVisible && !proj2.isVisible {
                return true
            }
            if proj2.isVisible && !proj1.isVisible {
                return false
            }
            else {
                return proj1.name.lowercased() < proj2.name.lowercased()
            }
        }
        
        for project in sorted {
            createCheckboxForProject(project)
        }
    }
    
    private func createCheckboxForProject(_ project: XcodeProject) {
        let box = NSButton(checkboxWithTitle: project.name, target: self, action: #selector(forceUpdate))
        box.state = project.isVisible ? .on : .off
        box.bind(.value, to: project, withKeyPath: "isVisible", options: [NSBindingOption.continuouslyUpdatesValue : true])
        stackView.addArrangedSubview(box)
    }
    
    @objc private func forceUpdate() {
        XcodeProjectManager.forceProjectUpdate()
    }
    
}

class FlippedClipView: NSClipView {
    override var isFlipped: Bool { return true }
}
