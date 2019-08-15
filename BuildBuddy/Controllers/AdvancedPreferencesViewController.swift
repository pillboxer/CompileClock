//
//  AdvancedPreferencesViewController.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 18/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class AdvancedPreferencesViewController: NSViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var stackView: NSStackView!

    // MARK: - Properties
    override var nibName: NSNib.Name? {
        return "AdvancedPreferencesViewController"
    }

    @objc private var daysWorkedPerYear = UserDefaults.numberOfDaysWorkedPerYear {
        didSet {
            UserDefaults.standard.set(daysWorkedPerYear, forKey: UserDefaults.DefaultsStepperKey.daysWorkedPerYear.rawValue)
        }
    }
    
    @objc private var hoursWorkedPerDay = UserDefaults.hoursWorkedPerDay {
        didSet {
            UserDefaults.standard.set(hoursWorkedPerDay, forKey: UserDefaults.DefaultsStepperKey.hoursWorkedPerDay.rawValue)
        }
    }
    
    @objc private var customDecimalPlaces = UserDefaults.customDecimalPlaces {
        didSet {
            UserDefaults.standard.set(customDecimalPlaces, forKey: UserDefaults.DefaultsStepperKey.customDecimalPlaces.rawValue)
        }
    }

    
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
        configureUI()
        
    }
    
   // MARK : - Private Methods
    private func configureUI() {
        for key in UserDefaults.DefaultsStepperKey.allCases {
            addLabelAndStackViewForStepperKey(key)
        }
        addDisplayTextStackView()
        addResetPreferencesUI()
        addViewLog()
    }
    
    private func addLabelAndStackViewForStepperKey(_ key: UserDefaults.DefaultsStepperKey) {
        let label = NSTextField(labelWithString: key.rawValue)
        #error("Do better")
        label.attributedStringValue = label.stringValue.tintedForDarkModeIfNecessary
        stackView.addArrangedSubview(label)
        
        let horizontalStackView = NSStackView()
        horizontalStackView.orientation = .horizontal
        let textField = NSTextField()
        textField.isEditable = false
        textField.isSelectable = false
        horizontalStackView.addArrangedSubview(textField)
        let stepper = NSStepper()
        horizontalStackView.addArrangedSubview(stepper)
        stepper.valueWraps = false
        
        switch key {
        case .customDecimalPlaces:
            stepper.minValue = 0
            stepper.maxValue = 4
        case .daysWorkedPerYear:
            stepper.minValue = 1
            stepper.maxValue = 365
        case .hoursWorkedPerDay:
            stepper.minValue = 1
            stepper.maxValue = 24
        }
        
        bind(stepper: stepper, to: textField, forKey: key)
        stackView.addArrangedSubview(horizontalStackView)
        addSeparator()
    }
    
    private func addDisplayTextStackView() {
        
        let horizontalStackView = NSStackView()
        horizontalStackView.orientation = .horizontal
        
        let todayInfoString = UserDefaults.DefaultsAdvancedKey.todayInfoText.rawValue
        let label = NSTextField(labelWithString: todayInfoString)
        #error("Do better")
        label.attributedStringValue = label.stringValue.tintedForDarkModeIfNecessary
        stackView.addArrangedSubview(label)
        
        let enabledButton = NSButton(checkboxWithTitle: "", target: nil, action: nil)
        horizontalStackView.addArrangedSubview(enabledButton)
        enabledButton.bind(.value, to: NSUserDefaultsController.shared, withKeyPath: "values.\(UserDefaults.DefaultsBoolKey.showsDisplayText.rawValue)", options: [NSBindingOption.continuouslyUpdatesValue : true])
        
        enabledButton.target = self
        enabledButton.action = #selector(updateStatusItem)
        
        displayOptionsPopUp.bind(.enabled, to: enabledButton, withKeyPath: "cell.state", options: [NSBindingOption.continuouslyUpdatesValue : true])
        displayOptionsPopUp.bind(.selectedValue, to: NSUserDefaultsController.shared, withKeyPath: "values.\(todayInfoString)", options: [NSBindingOption.continuouslyUpdatesValue : true])
        
        horizontalStackView.addArrangedSubview(displayOptionsPopUp)
        stackView.addArrangedSubview(horizontalStackView)
        addSeparator()
    }
    
    private lazy var displayOptionsPopUp: NSPopUpButton = {
        let popUp = NSPopUpButton()
        let displayOptions = String.DisplayTextOptions.allCases.map() { $0.rawValue.capitalized }
        popUp.addItems(withTitles: displayOptions)
        popUp.action = #selector(updateStatusItem)
        popUp.target = self
        return popUp
    }()
    
    @objc private func updateStatusItem() {
        let appDelegate = NSApp.delegate as? AppDelegate
        appDelegate?.loadDisplayText()
    }
    
    private func addResetPreferencesUI() {
        let label = NSTextField(labelWithString: "Reset Preferences")
        #error("Do better")
        label.attributedStringValue = label.stringValue.tintedForDarkModeIfNecessary
        stackView.addArrangedSubview(label)
        let button = NSButton(title: "Reset", target: self, action: #selector(showResetPreferencesConfirmationAlert))
        stackView.addArrangedSubview(button)
        addSeparator()
    }
    
    private func addViewLog() {
        let button = NSButton(title: "View Log", target: self, action: #selector(viewLog))
        stackView.addArrangedSubview(button)
    }
    
    @objc private func viewLog() {
        FetchLogUtility.openLog()
    }
    @objc private func resetPreferences() {
        closeAlert()
        UserDefaults.setInitialDefaults()
        view.window?.close()
        let alert = NSAlert()
        alert.messageText = "Successfully Reset Preferences"
        alert.runModal()
    }
    
    @objc private func showResetPreferencesConfirmationAlert() {
        let alert = NSAlert()
        alert.messageText = "Are you sure you want to reset your preferences?"
        alert.addButton(withTitle: "Okay")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .critical
        let result = alert.runModal()
        if result == .alertFirstButtonReturn {
            resetPreferences()
        }
    }
    
    @objc private func closeAlert() {
        NSApp.mainWindow?.attachedSheet?.close()
    }
    
    private func addSeparator() {
        let box = NSBox()
        box.boxType = .custom
        box.borderColor = NSAppearance.isDarkMode ? .white : .black
        box.frame = NSRect(x: 0, y: 0, width: view.frame.width, height: 1)
        stackView.addArrangedSubview(box)
    }
    
    private func bind(stepper: NSStepper, to textField: NSTextField, forKey key: UserDefaults.DefaultsStepperKey) {
        let keyPath: String
        
        switch key {
        case .customDecimalPlaces:
            keyPath = "customDecimalPlaces"
        case .daysWorkedPerYear:
            keyPath = "daysWorkedPerYear"
        case .hoursWorkedPerDay:
            keyPath = "hoursWorkedPerDay"
        }
        
        stepper.bind(.value, to: self, withKeyPath: keyPath, options: [NSBindingOption.continuouslyUpdatesValue : true])
        textField.bind(.value, to: self, withKeyPath: keyPath, options: [NSBindingOption.continuouslyUpdatesValue : true])
    }

    
}
