//
//  UploadLogWindowController.swift
//  CompileClock
//
//  Created by Henry Cooper on 28/08/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class HelpWindowController: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var emailTextField: NSTextField!
    @IBOutlet weak var sendButton: NSButton!
    @IBOutlet weak var messageTextView: NSTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var logAttachedButton: NSButton!
    @IBOutlet weak var yourMessageLabel: NSTextField!
    
    // MARK: - Properties
    let messageMinimum = 20
    let helpRequestMinimumSeconds = 3630.0
    let lastUploadDate = UserDefaults.lastHelpRequestDate.timeIntervalSince1970
    let licenseWindowController = LicenseWindowController()

    
    @IBAction func sendPushed(_ sender: Any) {
        sendButton.isEnabled = false
        spinner.startAnimation(nil)
        sendHelpRequest()
    }
    
    
    // MARK: - Initialisation
    init() {
        super.init(window: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var windowNibName: NSNib.Name? {
        return "HelpWindowController"
    }
    
    // MARK: - Life Cycle
    override func windowDidLoad() {
        super.windowDidLoad()
        emailTextField.delegate = self
        configureUI()
        validateTextField()
        setButtonTitle()
    }
    
    // MARK: - Private
    private var shouldAttachLog: Bool {
        return logAttachedButton.state == .on
    }
    
    private func configureUI() {
        window?.styleMask.remove(.resizable)
        window?.center()
        window?.title = "Help"
        spinner.isDisplayedWhenStopped = false
        sendButton.isEnabled = shouldEnableSendButton
        updateYourMessageLabel()
    }
    
    @IBAction func viewLicense(_ sender: Any) {
        let provider = LicensingProvider()
        let licensing = provider.licensing
        licenseWindowController.close()
        licenseWindowController.showWindow(nil)
        licenseWindowController.displayLicensing(licensing)
    }
    private func setButtonTitle() {
        let timeSinceUpload = Date().timeIntervalSince1970 - lastUploadDate
        let time = helpRequestMinimumSeconds - timeSinceUpload
        let formatted = String.prettyTime(time)
        sendButton.title = shouldEnableSendButton ? "Send" : formatted
    }
    
    private var shouldEnableSendButton: Bool {
        return lastUploadDate == 0
            || Date().timeIntervalSince1970 - lastUploadDate > helpRequestMinimumSeconds
    }
    
    private func sendHelpRequest() {
        HelpManager.shared.sendHelpRequest(email: emailTextField.stringValue, message: messageTextView.stringValue, withLog: shouldAttachLog) { error in
            
            if let error = error {
                LogUtility.updateLogWithEvent(.logUploaded(false))
                NSAlert.showSimpleAlert(title: "Error", message: error.description, isError: true, completionHandler: nil)
                self.spinner.stopAnimation(self)
                self.sendButton.isEnabled = self.shouldEnableSendButton
            }
                
            else {
                LogUtility.updateLogWithEvent(.logUploaded(true))
                NSAlert.showSimpleAlert(title: "Success", message: "Log Uploaded") {
                    self.window?.close()
                    DispatchQueue.main.async {
                        self.sendButton.isEnabled = self.shouldEnableSendButton
                        self.spinner.stopAnimation(self)
                    }
                }
            }
        }
    }
}

extension HelpWindowController:
NSControlTextEditingDelegate, NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        validateTextField()
        updateYourMessageLabel()
    }
    
    private func updateYourMessageLabel() {
        if messageTextView.stringValue.count < messageMinimum {
            yourMessageLabel.stringValue = "Your Message (\(messageMinimum - messageTextView.stringValue.count)):"
            yourMessageLabel.textColor = .red
        }
        else {
            yourMessageLabel.stringValue = "Your Message:"
            yourMessageLabel.textColor = .labelColor
        }
        
    }
    
    private func validateTextField() {
        sendButton.isEnabled = !emailTextField.stringValue.isEmpty
            && emailTextField.stringValue.isValidEmail
            && shouldEnableSendButton
            && messageTextView.stringValue.count > messageMinimum
    }
    
}
