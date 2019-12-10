//
//  NSUserNotification+Extensions.swift
//  CompileClock
//
//  Created by Henry Cooper on 25/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

enum NotificationType: String {
    case longestBuild = "Longest Build Reached"
    case mostBuilds = "Most Builds Reached"
}

extension NSUserNotification {
    
    static func deliverLongestBuildNotification(projectName: String, time: Double) {
        deliverNotification(type: .longestBuild, text: "Longest build time for \(projectName): \(String.prettyTime(time))")
    }
    
    static func deliverMostBuildsNotification(project: XcodeProject) {
        guard let most = project.mostBuildsInADay?.recurrances  else {
            return
        }
        let shouldShowNotification = project.lastMostBuildsNotificationDate == 0 || Calendar.numberOfDaysBetweenDates(Date(), Date(timeIntervalSinceReferenceDate: project.lastMostBuildsNotificationDate)) > 0
        
        if shouldShowNotification {
            deliverNotification(type: .mostBuilds, text: "Most builds for \(project.name): \(most)")
            project.lastMostBuildsNotificationDate = Date().timeIntervalSinceReferenceDate
        }
    }
    
    static private func deliverNotification(type: NotificationType, text: String) {
        let notification = NSUserNotification()
        notification.title = type.rawValue
        notification.subtitle = text
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
}
