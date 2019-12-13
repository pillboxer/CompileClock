//
//  LoginItemHelper.swift
//  CompileClock
//
//  Created by Henry Cooper on 13/12/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class LoginItemHelper {
    
    static let shared = LoginItemHelper()
    
    @discardableResult private func doShellScript() -> String? {
        let theLP = "/usr/bin/osascript"
        let theParms = ["-e", "tell application \"System Events\" to get the name of every login item"]
        let task = Process()
        task.launchPath = theLP
        task.arguments = theParms
        let outPipe = Pipe()
        task.standardOutput = outPipe
        task.launch()
        let fileHandle = outPipe.fileHandleForReading
        let data = fileHandle.readDataToEndOfFile()
        task.waitUntilExit()
        let status = task.terminationStatus
        if (status != 0) {
            return nil
        }
        else {
            return (NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String)
        }
    }
    
    private func executeScript(_ source: String) {
        if let appleScript = NSAppleScript(source: source) {
            var errorDict: NSDictionary? = nil
            appleScript.executeAndReturnError(&errorDict)
        }
    }
    
    var appIsInLoginItems: Bool {
        return doShellScript()?.contains("CompileClock") ?? false
    }
    
    var hasDeniedPermission: Bool {
        return doShellScript() == nil
    }
    
    func removeFromLoginItems() {
        let source = "tell application \"System Events\" to delete login item \"CompileClock\""
        executeScript(source)
    }
    
    func addToLoginItems() {
        doShellScript()
        let bundlePath = Bundle.main.bundlePath
        let preBundlePathString = "tell application \"System Events\" to make login item at end with properties {path:\""
        let postBundlePathString = "\", hidden:false}"
        let source = preBundlePathString + bundlePath + postBundlePathString
        executeScript(source)
    }
    
    
}
