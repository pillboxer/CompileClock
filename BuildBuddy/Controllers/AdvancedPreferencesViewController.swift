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
            UserDefaults.standard.set(daysWorkedPerYear, forKey: UserDefaults.DefaultsAdvancedKey.daysWorkedPerYear.rawValue)
        }
    }
    
    @objc private var hoursWorkedPerDay = UserDefaults.hoursWorkedPerDay {
        didSet {
            UserDefaults.standard.set(hoursWorkedPerDay, forKey: UserDefaults.DefaultsAdvancedKey.hoursWorkedPerDay.rawValue)
        }
    }
    
    @objc private var customDecimalPlaces = UserDefaults.customDecimalPlaces {
        didSet {
            UserDefaults.standard.set(customDecimalPlaces, forKey: UserDefaults.DefaultsAdvancedKey.customDecimalPlaces.rawValue)
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
        for key in UserDefaults.DefaultsAdvancedKey.allCases {
            if key == .derivedDataLocation {
                #warning("Change")
                continue
            }
            addLabelAndStackViewForKey(key)
        }

    }
    
    private func addLabelAndStackViewForKey(_ key: UserDefaults.DefaultsAdvancedKey) {
        let label = NSTextField(labelWithString: key.rawValue)
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
        default:
            break
        }
        
        bind(stepper: stepper, to: textField, forKey: key)
        stackView.addArrangedSubview(horizontalStackView)
        let box = NSBox()
        box.boxType = .separator
        stackView.addArrangedSubview(box)
    }
    
    private func bind(stepper: NSStepper, to textField: NSTextField, forKey key: UserDefaults.DefaultsAdvancedKey) {
        let keyPath: String
        
        switch key {
        case .customDecimalPlaces:
            keyPath = "customDecimalPlaces"
        case .daysWorkedPerYear:
            keyPath = "daysWorkedPerYear"
        case .hoursWorkedPerDay:
            keyPath = "hoursWorkedPerDay"
        default:
            return
        }
        
        stepper.bind(.value, to: self, withKeyPath: keyPath, options: [NSBindingOption.continuouslyUpdatesValue : true])
        textField.bind(.value, to: self, withKeyPath: keyPath, options: [NSBindingOption.continuouslyUpdatesValue : true])
    }

    
}
