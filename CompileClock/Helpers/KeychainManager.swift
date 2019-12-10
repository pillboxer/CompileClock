//
//  KeychainManager.swift
//  CompileClock
//
//  Created by Henry Cooper on 03/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
import KeychainAccess

class KeychainManager {
    
    static let shared = KeychainManager()
    
    enum KeychainDataType: String {
        case apiKey
    }
    
    func storeData(_ data: KeychainDataType, value: String) {
        let keychain = Keychain(service: "api.compileclock.com")
        keychain[data.rawValue] = value
    }
    
    func getData(_ data: KeychainDataType) -> String? {
        let keychain = Keychain(service: "api.compileclock.com")
        return keychain[data.rawValue]
        
    }
    
}
