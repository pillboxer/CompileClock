//
//  NSAlert+Extensions.swift
//  CompileClock
//
//  Created by Henry Cooper on 18/08/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

extension NSAlert {
    
    static func showSimpleAlert(title: String, message: String, isError: Bool = false, completionHandler: (() -> Void)?) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = isError ? .critical : .informational
            let run = alert.runModal()
            if run == .cancel {
                completionHandler?()
            }
        }
    }
    
    static func showSimpleChoiceAlert(title: String, message: String, completion: (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        let result = alert.runModal()
        if result == .alertFirstButtonReturn {
            completion(true)
        }
        else {
            completion(false)
        }
    }
    
}
