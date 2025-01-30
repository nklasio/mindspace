import Foundation
import SwiftData

@Model
class SensorReading {
    var timestamp: Date?
    var heartRate: Double?
    var oxygenLevel: Double?
    var rotationX: Double?
    var rotationY: Double?
    var rotationZ: Double?
    var accelerationX: Double?
    var accelerationY: Double?
    var accelerationZ: Double?
    
    @Relationship var session: Session?
    
    init(timestamp: Date = Date(), 
         heartRate: Double = 0,
         oxygenLevel: Double = 0,
         rotationX: Double = 0,
         rotationY: Double = 0,
         rotationZ: Double = 0,
         accelerationX: Double = 0,
         accelerationY: Double = 0,
         accelerationZ: Double = 0,
         session: Session? = nil) {
        self.timestamp = timestamp
        self.heartRate = heartRate
        self.oxygenLevel = oxygenLevel
        self.rotationX = rotationX
        self.rotationY = rotationY
        self.rotationZ = rotationZ
        self.accelerationX = accelerationX
        self.accelerationY = accelerationY
        self.accelerationZ = accelerationZ
        self.session = session
    }
} 
