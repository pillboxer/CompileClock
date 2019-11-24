//
//  HelpManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 23/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class HelpManager: NSObject, NSWindowDelegate {
    
    enum HelpUploadError: Error {
        case tooManyRequests
        case urlInvalid
        case uploadError(String)
        
        var description: String {
            switch self {
            case .tooManyRequests:
                return "Too many requests, please try again later"
            case .uploadError(let error):
                return "Something went wrong uploading: \(error)"
            case .urlInvalid:
                return "URL was invalid"
            }
        }
    }
    
    static var shared = HelpManager()
    private var helpController: HelpWindowController?
    
    func showHelpController() {
        helpController = HelpWindowController()
        helpController?.window?.delegate = self
        NSApp.activate(ignoringOtherApps: true)
        helpController?.showWindow(nil)
    }
    
    func windowWillClose(_ notification: Notification) {
        helpController = nil
    }
    
    func windowDidResignKey(_ notification: Notification) {
        helpController?.close()
    }
    
    func sendHelpRequest(email: String,
                         message: String,
                         withLog: Bool,
                         completion: @escaping (HelpUploadError?) -> Void) {
        
        APIManager.shared.sendHelpRequest(withEmail: email,
                                          message: message,
                                          logText: withLog ? LogUtility.log : nil) { response, error in
                                            
            if let error = error {
                completion(.uploadError(error.localizedDescription))
            }
                
            else if let response = response,
                let data = response.data {
                UserDefaults.lastLogUploadDate = Date(timeIntervalSince1970: data.lastRequestTime)
                completion(nil)
            }
        }
    }
}
