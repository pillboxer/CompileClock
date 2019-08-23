//
//  FetchingMenuItemViewController.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 14/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class FetchingMenuItemViewController: NSViewController {
    
    // MARK: - IBOutlets
    @IBOutlet var customView: NSView!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var projectNameLabel: NSTextField!
    @IBOutlet weak var projectCountLabel: NSTextField!
    
    // MARK: - Properties
    override var nibName: NSNib.Name? {
        return "FetchingMenuItemView"
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.startAnimation(self)
    }
    
    // MARK: - Initialisation
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
