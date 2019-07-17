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
        
        let dailyAverageText: String
        let averageBuildTimeText: String
        
        if currentProject.builds.count < 50 {
            let numberRemaining = 50 - currentProject.builds.count
            averageBuildTimeText = "\(numberRemaining) More Builds Needed"
        }
        else {
            averageBuildTimeText = String.prettyTime(currentProject.totalAverageBuildTime)
        }
        
        if currentProject.numberOfDaysWithBuilds < 30 {
            let numberRemaining = 30 - currentProject.numberOfDaysWithBuilds
            dailyAverageText = "\(numberRemaining) More Build Days Needed"
        }
        else {
            let dailyAverage = currentProject.dailyAverageNumberOfBuilds
            dailyAverageText = "\(dailyAverage) builds per day"
        }
        
        dailyAverageLabel.stringValue = dailyAverageText
        averageBuildTimeLabel.stringValue = averageBuildTimeText
    }
    
    private func configureMostBuildsLabel() {
        guard let mostBuilds = currentProject.mostBuildsInADay else {
            mostBuildsLabel.isHidden = true
            return
        }
        mostBuildsLabel.stringValue = "\(mostBuilds.recurrances) - \(formatter.string(from: mostBuilds.date))"
    }
    
}
