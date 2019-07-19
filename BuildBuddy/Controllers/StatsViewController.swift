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
    @IBOutlet weak var timeSpentLabel: NSTextField!
    @IBOutlet weak var improveAccuracyLabel: NSTextField!
    @IBOutlet weak var inaccurateDataLabel: NSTextField!
    @IBOutlet weak var peekButton: NSButton!
    
    @IBAction func peekButtonTapped(_ sender: Any) {
        viewModel.bypassChecks = (peekButton.state == .on)
        inaccurateDataLabel.isHidden = (peekButton.state == .off)
        reloadUI()
    }
    // MARK: - Properties
    override var nibName: NSNib.Name? {
        return "StatsViewController"
    }
    let viewModel = StatsViewModel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        inaccurateDataLabel.isHidden = true
    }
    
    func loadWithProject(_ project: XcodeProject) {
        viewModel.project = project
        reloadUI()
    }
    
    private func reloadUI() {
        titleLabel.stringValue = viewModel.project.name
        configurePeekButton()
        configureLongestBuildLabel()
        configureDynamicLabels()
        configureMostBuildsLabel()
    }
    
    private func configureLongestBuildLabel() {
        if let longestBuildString = viewModel.longestBuildString {
            longestBuildTimeLabel.stringValue = longestBuildString
        }
    }
    
    private func configurePeekButton() {
        peekButton.isHidden = !viewModel.peekButtonShouldShow
    }
    
    private func configureDynamicLabels() {
        averageBuildTimeLabel.stringValue = viewModel.averageBuildTimeString
        dailyAverageLabel.stringValue = viewModel.dailyAverageBuildsString
        timeSpentLabel.stringValue = viewModel.workingTimePercentageString
    }
    
    private func configureAverageBuildTime() {
        averageBuildTimeLabel.stringValue = viewModel.averageBuildTimeString
    }
    
    private func configureMostBuildsLabel() {
        guard let mostBuildsString = viewModel.mostBuildsInADayString else {
            return
        }
        mostBuildsLabel.stringValue = mostBuildsString
    }
    
}
