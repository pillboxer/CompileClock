//
//  LicenseChangeBroadcaster.swift
//  CompileClock
//
//  Created by Henry Cooper on 30/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

/// Wraps a call to Notification Center
class LicenseChangeBroadcaster {
    
    let notificationCenter: NotificationCenter
    
    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }
    
    func broadcast(_ licensing: Licensing) {
        notificationCenter.post(name: Licensing.licenseChangedNotification, object: self, userInfo: licensing.userInfo)
    }
    
    
}
