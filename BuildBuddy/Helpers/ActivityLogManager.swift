//
//  ActivityLogManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 10/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
import Gzip

class ActivityLogManager {
    
    static func buildTypeAndSuccessTuple(fromLog activityLog: Data?) -> (XcodeBuild.BuildType, Bool)? {
        #warning("Need more robust method of checking build type")
        guard let activityLog = activityLog,
        let gzipped = try? activityLog.gunzipped(),
            let activityLogString = String(data: gzipped, encoding: .utf8) else {
            return nil
        }
        let type: XcodeBuild.BuildType
        let lastCharacters = activityLogString.suffix(20)
        
        if lastCharacters.contains("stopped") {
            return nil
        }
        
        if activityLogString.contains("libXCTestSwiftSupport") {
            type = .test
        }
        else if lastCharacters.lowercased().contains("clean") {
            type = .clean
        }
        else {
            type = .run
        }

        let success = lastCharacters.contains("succeeded")
        return (type, success)
    }
    
    
}
