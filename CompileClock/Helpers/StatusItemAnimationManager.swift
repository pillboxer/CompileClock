//
//  StatusItemAnimationManager.swift
//  CompileClock
//
//  Created by Henry Cooper on 10/08/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class StatusItemAnimationManager {
    
    private var statusItem: NSStatusItem
    
    // MARK: - Initialisation
    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
    }
    
    // MARK: - Exposed Methods
    
    var loadingItem: NSStatusItem {
        let layer = CALayer()
        statusItem.button?.layer = layer
        
        let image = NSImage(named: "rotatingClock")
        statusItem.button?.layer?.contents = image
        
        let basicAnimation = CABasicAnimation(keyPath:"transform.rotation")
        basicAnimation.fromValue = 2.0 * .pi
        basicAnimation.toValue = 0.0
        layer.contentsGravity = .resizeAspect
        basicAnimation.duration = 1.0
        basicAnimation.repeatCount = Float.infinity
        
        // Set the position of the layer to the center of the button
        let layerPosition = CGPoint(x: layer.frame.width / 2.0, y: layer.frame.height / 2.0)
        // Have the point at which we anchor our animations around be the center of the layer (unit circle)
        let anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        layer.position = layerPosition
        layer.anchorPoint = anchorPoint
        
        
        statusItem.button?.layer?.add(basicAnimation, forKey: "rotatingAnimation")
        return statusItem
    }
    
    
    
    
    
}
