//
//  XcodeProjectMenuItem.swift
//  CompileClock
//
//  Created by Henry Cooper on 06/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class XcodeProjectMenuItem: NSMenuItem {
    
    // MARK: - Properties
    let project: XcodeProject
    var timeBlock: String.TimeBlock?
    var period: String.BuildTimePeriod?
    
    // MARK: - Initialisation
    init(_ project: XcodeProject) {
        self.project = project
        super.init(title: "", action: nil, keyEquivalent: "")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
