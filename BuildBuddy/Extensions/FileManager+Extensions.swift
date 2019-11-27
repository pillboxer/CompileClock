//
//  FileManager+Extensions.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 13/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

extension FileManager {
    
    private static var applicationSupport: URL {
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    }
    
    static var buildBuddyApplicationSupportFolder: URL {
        return applicationSupport.appendingPathComponent("BuildBuddy")
    }
    
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
    
    private static func deleteFile(_ file: URL) {
        let manager = FileManager.default
        do {
            try manager.removeItem(at: file)
        }
        catch let error {
            print(error)
        }
    }
    
    static func trashFile(_ file: URL) -> Bool {
        let manager = FileManager.default
        do {
            try manager.trashItem(at: file, resultingItemURL: nil)
            return true
        }
        catch let error {
            print(error.localizedDescription)
            return false
        }
    }
    
    static func stringFromFile(_ file: URL) -> String? {
        
        do {
            return try String(contentsOf: file)
        }
        catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func updateFile(_ file: URL, withText text: String) {
                
        guard let textData = text.data(using: .utf8) else {
            return
        }
        
        purgeFileIfNecessary(file)
        
        if folderIsValid(file.path),
            let fileHandle = try? FileHandle(forWritingTo: file) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(textData)
            fileHandle.closeFile()
        }
        else {
            try? textData.write(to: file, options: .atomic)
        }
    }
    
    private static func purgeFileIfNecessary(_ file: URL) {
        if let text = try? String(contentsOf: file), text.count > 5000 {
            deleteFile(file)
            let purgeText = "File Purged At \(Date().description)\n\n"
            let filePurgedInfo = purgeText.data(using: .utf8)
            try? filePurgedInfo?.write(to: file, options: .atomic)
        }
    }
    
    static var libraryFolder: String? {
        guard let libraryFolder = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            return nil
        }
        return libraryFolder
    }
    
}
