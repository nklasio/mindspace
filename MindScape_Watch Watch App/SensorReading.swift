//
//  Item.swift
//  MindScape
//
//  Created by Niklas Stambor on 29.01.25.
//

import Foundation
import SwiftData

@Model
public class SensorReading {
    var timestamp: Date
    var heartRate: Double
    var rotationX: Double
    var rotationY: Double
    var rotationZ: Double
    var accelerationX: Double
    var accelerationY: Double
    var accelerationZ: Double
    
    init(timestamp: Date = Date(), 
         heartRate: Double = 0,
         rotationX: Double = 0,
         rotationY: Double = 0,
         rotationZ: Double = 0,
         accelerationX: Double = 0,
         accelerationY: Double = 0,
         accelerationZ: Double = 0) {
        self.timestamp = timestamp
        self.heartRate = heartRate
        self.rotationX = rotationX
        self.rotationY = rotationY
        self.rotationZ = rotationZ
        self.accelerationX = accelerationX
        self.accelerationY = accelerationY
        self.accelerationZ = accelerationZ
    }
}
