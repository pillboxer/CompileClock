//
//  BuildBuddyTests.swift
//  BuildBuddyTests
//
//  Created by Henry Cooper on 12/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import XCTest
@testable import CompileClock

class BuildBuddyTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

class LicenseViewControllerTests: XCTestCase {
    
    var controller: LicenseViewController!
    
    override func setUp() {
        // Load the window controller from its nib ...
        let windowController = LicenseWindowController()
        _ = windowController.window
        // ... and then get the initialized controller:
        controller = windowController.licenseViewController
    }
    
    func testLicenseeTextField_IsConnected() {
        XCTAssertNotNil(controller.licenseeTextField)
    }
    
    
    func testDisplayEmptyForm_EmptiesTextFields() {
        controller.licenseeTextField.stringValue = "something"
        controller.licenseCodeTextField.stringValue = "something"
        controller.displayEmptyTextField()
        XCTAssertEqual(controller.licenseeTextField.stringValue, "")
        XCTAssertEqual(controller.licenseCodeTextField.stringValue, "")
    }
    
    func testDisplayLicense_FillsLicenseTextFields() {
        let license = License(licensee: "lol", code: "1234")
        controller.licenseeTextField.stringValue = ""
        controller.displayLicenseInformation(license)
        XCTAssertEqual(controller.licenseCodeTextField.stringValue, "1234")
    }
}
