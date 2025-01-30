import Foundation
import SwiftData

@Model
class Session {
    var startTime: Date?
    var endTime: Date?
    @Relationship(deleteRule: .cascade, inverse: \SensorReading.session) var readings: [SensorReading]?
    var name: String?
    var isFavorite: Bool?

    
    init(startTime: Date = Date(), 
         endTime: Date? = nil,
         readings: [SensorReading] = [],
         isFavorite: Bool? = false,
         name: String? = nil ) {
        self.startTime = startTime
        self.endTime = endTime
        self.readings = readings
        self.name = name ?? "Session \(startTime.formatted(date: .abbreviated, time: .shortened))"
             self.isFavorite = isFavorite
    }
} 
