import Foundation
import SwiftData

@Model
class Session {
    var startTime: Date?
    var endTime: Date?
    @Relationship(deleteRule: .cascade, inverse: \SensorReading.session) var readings: [SensorReading]?
    var name: String?
    var isFavorite: Bool?
    var incidents: [Incident]?
    var quality: Double?
    
    init(startTime: Date = Date(), 
         endTime: Date? = nil,
         readings: [SensorReading] = [],
         isFavorite: Bool? = false,
         name: String? = nil,
         incidents: [Incident] = [],
         quality: Double = 0) {
        self.startTime = startTime
        self.endTime = endTime
        self.readings = readings
        self.name = name ?? "Session \(startTime.formatted(date: .abbreviated, time: .shortened))"
        self.isFavorite = isFavorite
        self.incidents = incidents
        self.quality = quality
    }
    
    func addIncident(severity: IncidentSeverity, heartRate: Double, movement: Double) {
        let incident = Incident(
            timestamp: Date(),
            severity: severity,
            heartRate: heartRate,
            movement: movement
        )
        if incidents == nil {
            incidents = []
        }
        incidents?.append(incident)
    }
}

struct Incident: Codable {
    let id: UUID
    let timestamp: Date
    let severity: IncidentSeverity
    let heartRate: Double
    let movement: Double
    
    init(timestamp: Date, severity: IncidentSeverity, heartRate: Double, movement: Double) {
        self.id = UUID()
        self.timestamp = timestamp
        self.severity = severity
        self.heartRate = heartRate
        self.movement = movement
    }
}

enum IncidentSeverity: String, Codable {
    case mild
    case moderate
    case severe
}


