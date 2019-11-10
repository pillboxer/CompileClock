//
//  UploadLogWindowController.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 28/08/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class UploadLogWindowController: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var emailTextField: NSTextField!
    @IBOutlet weak var sendButton: NSButton!
    @IBOutlet weak var logTextView: NSTextView!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    @IBAction func sendLogPushed(_ sender: Any) {
        sendButton.isEnabled = false
        spinner.isHidden = false
        spinner.startAnimation(nil)
        uploadLog()
    }
    override var windowNibName: NSNib.Name? {
        return "UploadLogWindowController"
    }
    
    init() {
        super.init(window: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        emailTextField.delegate = self
        configureUI()
        validateTextField()
        configureTextView()
    }
    
    private func configureUI() {
        window?.center()
        window?.title = "Upload Log"
        sendButton.isEnabled = shouldEnableSendButton
    }
    
    private func configureTextView() {
        if let log = LogUtility.log {
            logTextView.string = log
        }
    }
    
    private var shouldEnableSendButton: Bool {
        let lastUploadDate = UserDefaults.lastLogUploadDate.timeIntervalSince1970
        return lastUploadDate == 0 || Date().timeIntervalSince1970 - lastUploadDate > 60
    }
    
    private func uploadLog() {
        LogUtility.uploadLog(withEmail: emailTextField.stringValue) { (error) in
            if let error = error {
                LogUtility.updateLogWithEvent(.logUploaded(false))
                NSAlert.showSimpleAlert(title: "Error", message: error.description, isError: true, completionHandler: nil)
            }
            else {
                LogUtility.updateLogWithEvent(.logUploaded(true))
                NSAlert.showSimpleAlert(title: "Success", message: "Log Uploaded") {
                    self.window?.close()
                }
            }
            DispatchQueue.main.async {
                self.sendButton.isEnabled = self.shouldEnableSendButton
                self.spinner.isHidden = true
            }
        }
    }

}

extension UploadLogWindowController: NSControlTextEditingDelegate, NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        validateTextField()
    }
    
    private func validateTextField() {
        sendButton.isEnabled = !emailTextField.stringValue.isEmpty && emailTextField.stringValue.isValidEmail && shouldEnableSendButton
    }
    
}
