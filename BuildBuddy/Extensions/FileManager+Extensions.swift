//
//  FileManager+Extensions.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 13/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

extension FileManager {
    
    static func lastModificationDateForFile(_ file: String) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file),
            let modificationDate = attributes[FileAttributeKey.modificationDate] as? Date {
            return modificationDate
        }
        return Date(timeIntervalSince1970: 0)
    }
    
    static func folderIsValid(_ folder: String) -> Bool {
        return FileManager.default.fileExists(atPath: folder)
    }
}
