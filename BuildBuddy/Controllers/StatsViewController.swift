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
    @IBOutlet weak var averageBuildTimeLabel: NSTextField!
    @IBOutlet weak var longestBuildTimeLabel: NSTextField!
    @IBOutlet weak var mostBuildsLabel: NSTextField!
    @IBOutlet weak var dailyAverageLabel: NSTextField!
    
    // MARK: - Properties
    override var nibName: NSNib.Name? {
        return "StatsViewController"
    }
    var currentProject: XcodeProject!
    
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
    }
    
    deinit {
        print("Stats gone")
    }
    
    func loadWithProject(_ project: XcodeProject) {
        currentProject = project
        reloadUI()
    }
    
    private func reloadUI() {
        titleLabel.stringValue = currentProject.name
        configureLongestBuildLabel()
        configureAverageBuildTimeLabels()
        configureMostBuildsLabel()
        
    }
    
    private func configureLongestBuildLabel() {
        if let longestBuild = currentProject.longestBuild {
            longestBuildTimeLabel.stringValue = "\(String.prettyTime(longestBuild.totalBuildTime)) - \(formatter.string(from: longestBuild.buildDate))"
        }
    }
    
    private func configureAverageBuildTimeLabels() {
        guard currentProject.builds.count > 20 else {
            // FIXME: -
            dailyAverageLabel.stringValue = "Awaiting More Data"
            averageBuildTimeLabel.stringValue = "Awaiting More Data"
            return
        }
        let dailyAverage = currentProject.dailyAverageNumberOfBuilds
        dailyAverageLabel.stringValue = "\(dailyAverage) builds per day"
        averageBuildTimeLabel.stringValue = String.prettyTime(currentProject.totalAverageBuildTime)
    }
    
    private func configureMostBuildsLabel() {
        guard let mostBuilds = currentProject.mostBuildsInADay else {
            mostBuildsLabel.isHidden = true
            return
        }
        mostBuildsLabel.stringValue = "\(mostBuilds.recurrances) - \(formatter.string(from: mostBuilds.date))"
    }
    
}
