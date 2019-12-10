//
//  StatsViewController.swift
//  CompileClock
//
//  Created by Henry Cooper on 16/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class StatsViewController: NSViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var topLabel: NSTextField!
    @IBOutlet weak var secondLabel: NSTextField!
    @IBOutlet weak var thirdLabel: NSTextField!
    @IBOutlet weak var fourthLabel: NSTextField!
    @IBOutlet weak var fifthLabel: NSTextField!
    
    @IBOutlet weak var topLabelTitle: NSTextField!
    @IBOutlet weak var secondLabelTitle: NSTextField!
    @IBOutlet weak var fifthLabelTitle: NSTextField!
    @IBOutlet weak var improveAccuracyLabel: NSTextField!
    @IBOutlet weak var peekButton: NSButton!
    
    // MARK: - Action Methods
    @IBAction func peekButtonTapped(_ sender: Any) {
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
    }
    
    // MARK: - Exposed Methods
    func loadWithProject(_ project: XcodeProject) {
        viewModel.project = project
        reloadUI()
    }
    
    // MARK : - Private Methods
    private func reloadUI() {
        configureLabelsForPeekState(peekButton.state)
        titleLabel.stringValue = viewModel.project.name
        
    }
    
    private func configureLabelsForPeekState(_ state: NSControl.StateValue) {
        if state == .off {
            configurePeekStateOffLabels()
            configureImproveAccuracyLabel()
            configureTimeSpentTitleLabel()
        }
        else {
            configurePeekStateOnLabels()
        }
    }
    
    private func configureTimeSpentTitleLabel() {
        let font = NSFont.systemFont(ofSize: 13)
        let superFont = NSFont.systemFont(ofSize: 11)
        let string = NSMutableAttributedString(string: "Working Time Spent Building*", attributes: [.font:font])
        string.setAttributes([.font: superFont, .baselineOffset: 3], range: NSRange(location: 27, length: 1))
        fifthLabelTitle.attributedStringValue = string
    }
    
    private func configureImproveAccuracyLabel() {
        let font = NSFont.systemFont(ofSize: 9)
        let superFont = NSFont.systemFont(ofSize: 6)
        let string = NSMutableAttributedString(string: "*For more accuracy, set the number of days and hours you work in the Advanced tab in Preferences", attributes: [.font:font, .foregroundColor:NSColor.black])
        string.setAttributes([.font: superFont, .baselineOffset: 3], range: NSRange(location: 0, length: 1))
        string.setAlignment(.center, range: NSRange(location: 0, length: string.length))
        improveAccuracyLabel.attributedStringValue = string
    }
    
    private func configurePeekStateOffLabels() {
        topLabel.stringValue = viewModel.longestBuildString
        secondLabel.stringValue = viewModel.averageBuildTimeString
        thirdLabel.stringValue = viewModel.mostBuildsInADayString
        fourthLabel.stringValue = viewModel.dailyAverageBuildsString
        fifthLabel.stringValue = viewModel.workingTimePercentageString
        
        configureTimeSpentTitleLabel()
        configureImproveAccuracyLabel()
    }
    
    private func configurePeekStateOnLabels() {
        topLabel.setLoading()
        secondLabel.setLoading()
        thirdLabel.setLoading()
        fourthLabel.setLoading()
        fifthLabel.setLoading()
        viewModel.compare { (payload, error) in
            if let payload = payload {
                DispatchQueue.main.async {
                    let comparisonData = self.viewModel.comparisonData(payload)
                    self.topLabel.attributedStringValue = comparisonData.comparedAverageTimeString
                    self.secondLabel.attributedStringValue = comparisonData.comparedLongestString
                    self.thirdLabel.attributedStringValue = comparisonData.comparedMostString
                    self.fourthLabel.attributedStringValue = comparisonData.comparedAverageBuildsString
                    self.fifthLabel.attributedStringValue = comparisonData.comparedPercentageString
                }
            }
            else if let error = error {
                DispatchQueue.main.async {
                    self.topLabel.clear()
                    self.secondLabel.clear()
                    self.thirdLabel.setError()
                    self.fourthLabel.clear()
                    self.fifthLabel.clear()
                    self.improveAccuracyLabel.stringValue = error.localizedDescription
                    self.improveAccuracyLabel.textColor = .red
                }

            }
        }
    }
    
}

extension NSTextField {
    
    func clear() {
        stringValue = ""
    }
    
    func setLoading() {
        stringValue = "Loading"
    }
    
    func setError() {
        stringValue = "Could not retrieve statistics"
    }
}
