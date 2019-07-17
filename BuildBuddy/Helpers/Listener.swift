//
//  Listener.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 14/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class Listener: NSObject {
    
    static let shared = Listener()
    
    private override init() {
        super.init()
        configureObservations()
    }
    
    private func configureObservations() {
        observeDefaults()
    }
    
    private func observeDefaults() {
        for key in UserDefaults.allKeys {
            UserDefaults.standard.addObserver(self, forKeyPath: key, options: [NSKeyValueObservingOptions.new], context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        changeDefaults()
    }
    
    private(set) var defaultsChanged = false
    
    @objc private func changeDefaults() {
        defaultsChanged = true
    }
    
    func resetDefaults() {
        defaultsChanged = false
    }
    
}
