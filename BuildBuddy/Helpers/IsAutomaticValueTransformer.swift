//
//  IsAutomaticValueTransformer.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 12/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class IsAutomaticValueTransformer: ValueTransformer {

    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        return value as? Int == 0
    }
}

extension IsAutomaticValueTransformer {
    static let name = NSValueTransformerName(rawValue: "IsAutomaticValueTransformer")
}
