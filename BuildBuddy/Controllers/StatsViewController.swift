//
//  StatsViewController.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 16/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class StatsViewController: NSViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var longestBuildTimeLabel: NSTextField!
    
    // MARK: - Properties
    override var nibName: NSNib.Name? {
        return "StatsViewController"
    }
    
    lazy var formatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func loadWithProject(_ project: XcodeProject) {
        titleLabel.stringValue = project.name!
        if let longestBuild = project.longestBuild {
            longestBuildTimeLabel.stringValue = "\(String.prettyTime(longestBuild.totalBuildTime)) - \(formatter.string(from: longestBuild.buildDate))"
        }
    }
    
}
