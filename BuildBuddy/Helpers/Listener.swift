//
//  Listener.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 14/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class Listener: NSObject {
    
    // MARK: - Properties
    static let shared = Listener()
    private(set) var defaultsChanged = false

    // MARK: - Initialisation
    private override init() {
        super.init()
        configureObservations()
    }
    
    // MARK : - Private Methods
    private func configureObservations() {
        observeDefaults()
    }
    
    @objc private func changeDefaults() {
        defaultsChanged = true
    }
    
    private func observeDefaults() {
        for key in UserDefaults.allKeys {
            UserDefaults.standard.addObserver(self, forKeyPath: key, options: [NSKeyValueObservingOptions.new], context: nil)
        }
    }
    
    // MARK: - Exposed Methods
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        changeDefaults()
    }
        
    func resetDefaultsChangedStatus() {
        defaultsChanged = false
    }
    
}
