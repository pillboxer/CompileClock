//
//  MenuPreferencesViewController.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 11/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class MenuPreferencesViewController: NSViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var stackView: NSStackView!
    
    // MARK: - Properties
    override var nibName: NSNib.Name? {
        return "MenuPreferencesViewController"
    }
    
    private var dateButton = NSButton()
    private let popover = DatePickerPopoverViewController()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        popover.delegate = self
        addCheckBoxes()
    }

    
    // MARK: - Initialisation
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK : - Private Methods
    private func addCheckBoxes() {
        for period in String.BuildTimePeriod.allCases {
            let checkbox = NSButton(checkboxWithTitle: period.pretty, target: self, action: nil)
            checkbox.attributedTitle = period.pretty.tintedForDarkModeIfNecessary
            checkbox.bind(.value, to: NSUserDefaultsController.shared, withKeyPath: "values.\(period.defaultsBoolKey.rawValue)", options: [NSBindingOption.continuouslyUpdatesValue: true])
            if period == .custom {
                stackView.addArrangedSubview(horizontalStackViewForCustomCheckbox(checkbox))
                stackView.addArrangedSubview(popUpsStackView(checkbox, period: period))
                continue
            }
            stackView.addArrangedSubview(checkbox)
            stackView.addArrangedSubview(popUpsStackView(checkbox, period: period))
            let line = NSBox()
            
            line.boxType = .separator
            stackView.addArrangedSubview(line)
        }
    }
    
    private func horizontalStackViewForCustomCheckbox(_ checkbox: NSButton) -> NSStackView {
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.addArrangedSubview(checkbox)
        dateButton = NSButton(title: "", target: self, action: #selector(showDatePickerPopover(_:)))
        dateButton.bind(.enabled, to: checkbox, withKeyPath: "cell.state", options: [NSBindingOption.continuouslyUpdatesValue : true])
        dateButton.image = NSImage(named: NSImage.followLinkFreestandingTemplateName)
        dateButton.setButtonType(.momentaryPushIn)
        dateButton.bezelStyle = .inline
        stackView.addArrangedSubview(dateButton)
        return stackView
    }
    
    private func popUpsStackView(_ checkbox: NSButton, period: String.BuildTimePeriod) -> NSStackView {
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        
        let timeBlocksPopUp = NSPopUpButton(frame: checkbox.frame, pullsDown: false)
        let timeBlocks = String.TimeBlock.allCases.map() { $0.rawValue.capitalized }
        timeBlocksPopUp.addItems(withTitles: timeBlocks)
        timeBlocksPopUp.bind(.selectedValue, to: NSUserDefaultsController.shared, withKeyPath: "values.\(period.rawValue)", options: [NSBindingOption.continuouslyUpdatesValue: true])
        timeBlocksPopUp.bind(.enabled, to: checkbox, withKeyPath: "cell.state", options: [NSBindingOption.continuouslyUpdatesValue : true])
        stackView.addArrangedSubview(timeBlocksPopUp)
        return stackView
    }
    
    @objc private func showDatePickerPopover(_ sender: NSButton) {
        present(popover, asPopoverRelativeTo: dateButton.bounds, of: dateButton, preferredEdge: .maxX, behavior: .transient)
    }
}

extension MenuPreferencesViewController: DatePickerPopoverViewControllerDelegate {
    
    func datePickerPopoverViewControllerDidTapSave(_ controller: DatePickerPopoverViewController) {
        dismiss(popover)
    }
    
}
