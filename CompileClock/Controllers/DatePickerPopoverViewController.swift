//
//  DatePickerPopoverViewController.swift
//  CompileClock
//
//  Created by Henry Cooper on 11/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

protocol DatePickerPopoverViewControllerDelegate: class {
    func datePickerPopoverViewControllerDidTapSave(_ controller: DatePickerPopoverViewController)
}

class DatePickerPopoverViewController: NSViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var startDatePicker: NSDatePicker!
    @IBOutlet weak var endDatePicker: NSDatePicker!
    
    // MARK: - Action Methods
    @IBAction func didTapSave(_ sender: Any) {
        guard startDatePicker.dateValue < endDatePicker.dateValue else {
            return
        }
        UserDefaults.set(startDate: startDatePicker.dateValue, endDate: endDatePicker.dateValue)
        delegate?.datePickerPopoverViewControllerDidTapSave(self)
    }
    
    // MARK: - Initialisation
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    weak var delegate: DatePickerPopoverViewControllerDelegate?
    override var nibName: NSNib.Name? {
        return "DatePickerPopoverViewController"
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startDatePicker.minDate = XcodeProjectManager.earliestBuildDate
        endDatePicker.minDate = XcodeProjectManager.earliestBuildDate
        startDatePicker.maxDate = Date()
        endDatePicker.maxDate = Date()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        startDatePicker.dateValue = UserDefaults.customStartDate
        endDatePicker.dateValue = UserDefaults.customEndDate
    }
}
