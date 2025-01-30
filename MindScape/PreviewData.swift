import Foundation
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Session.self,
            SensorReading.self,
            configurations: config
        )
        
        // Create sample sessions and incidents
        let dates = (-7...0).map { dayOffset in
            Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
        }
        
        for date in dates {
            let session = Session(
                startTime: date,
                endTime: Calendar.current.date(byAdding: .hour, value: 8, to: date),
                quality: Double.random(in: 70...95)
            )
            
            // Add random incidents
            if Bool.random() {
                session.addIncident(
                    severity: [IncidentSeverity.mild, .moderate, .severe].randomElement()!,
                    heartRate: Double.random(in: 70...120),
                    movement: Double.random(in: 0...1)
                )
            }
            
            // Add sample readings
            let readings = stride(from: 0, to: 8*60, by: 5).map { minutes in
                let timestamp = Calendar.current.date(byAdding: .minute, value: minutes, to: date)!
                return SensorReading(
                    timestamp: timestamp,
                    heartRate: Double.random(in: 50...80),
                    rotationX: Double.random(in: -2...2),
                    rotationY: Double.random(in: -2...2),
                    rotationZ: Double.random(in: -2...2),
                    accelerationX: Double.random(in: -0.5...0.5),
                    accelerationY: Double.random(in: -0.5...0.5),
                    accelerationZ: Double.random(in: -0.5...0.5),
                    session: session
                )
            }
            
            session.readings = readings
            container.mainContext.insert(session)
        }
        
        return container
    } catch {
        fatalError("Failed to create preview container: \(error.localizedDescription)")
    }
}() 