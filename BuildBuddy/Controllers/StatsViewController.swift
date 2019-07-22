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
    @IBOutlet weak var timeSpentTitleLabel: NSTextField!
    @IBOutlet weak var timeSpentLabel: NSTextField!
    @IBOutlet weak var improveAccuracyLabel: NSTextField!
    @IBOutlet weak var inaccurateDataLabel: NSTextField!
    @IBOutlet weak var peekButton: NSButton!
    
    // MARK: - Action Methods
    @IBAction func peekButtonTapped(_ sender: Any) {
        viewModel.bypassChecks = (peekButton.state == .on)
        inaccurateDataLabel.isHidden = (peekButton.state == .off)
        reloadUI()
    }
    // MARK: - Properties
    override var nibName: NSNib.Name? {
        return "StatsViewController"
    }
    private let viewModel = StatsViewModel()
    
    // MARK: - Initialisation
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        inaccurateDataLabel.isHidden = true
    }
    
    // MARK: - Exposed Methods
    func loadWithProject(_ project: XcodeProject) {
        viewModel.project = project
        reloadUI()
    }
    
    // MARK : - Private Methods
    private func reloadUI() {
        titleLabel.stringValue = viewModel.project.name
        configurePeekButton()
        configureLongestBuildLabel()
        configureDynamicLabels()
        configureImproveAccuracyLabel()
        configureTimeSpentTitleLabel()
        configureMostBuildsLabel()
    }
    
    private func configureTimeSpentTitleLabel() {
        let font = NSFont.systemFont(ofSize: 13)
        let superFont = NSFont.systemFont(ofSize: 11)
        let string = NSMutableAttributedString(string: "Working Time Spent Building*", attributes: [.font:font])
        string.setAttributes([.font: superFont, .baselineOffset: 3], range: NSRange(location: 27, length: 1))
        timeSpentTitleLabel.attributedStringValue = string
    }
    
    private func configureLongestBuildLabel() {
        if let longestBuildString = viewModel.longestBuildString {
            longestBuildTimeLabel.stringValue = longestBuildString
        }
    }
    
    private func configureImproveAccuracyLabel() {
        let font = NSFont.systemFont(ofSize: 9)
        let superFont = NSFont.systemFont(ofSize: 6)
        let string = NSMutableAttributedString(string: "*For more accuracy, set the number of days and hours you work in the Advanced tab in Preferences", attributes: [.font:font])
        string.setAttributes([.font: superFont, .baselineOffset: 3], range: NSRange(location: 0, length: 1))
        string.setAlignment(.center, range: NSRange(location: 0, length: string.length))
        improveAccuracyLabel.attributedStringValue = string
    }
    
    private func configurePeekButton() {
        peekButton.isHidden = !viewModel.peekButtonShouldShow
    }
    
    private func configureDynamicLabels() {
        averageBuildTimeLabel.stringValue = viewModel.averageBuildTimeString
        dailyAverageLabel.stringValue = viewModel.dailyAverageBuildsString
        timeSpentLabel.stringValue = viewModel.workingTimePercentageString
    }
    
    private func configureMostBuildsLabel() {
        guard let mostBuildsString = viewModel.mostBuildsInADayString else {
            return
        }
        mostBuildsLabel.stringValue = mostBuildsString
    }
    
}
