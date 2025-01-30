//
//  MindScapeApp.swift
//  MindScape
//
//  Created by Niklas Stambor on 29.01.25.
//

import SwiftUI
import SwiftData

@main
struct MindScapeApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let config = ModelConfiguration(
                schema: Schema([Session.self, SensorReading.self]),
                cloudKitDatabase: .private("iCloud.de.nstambor.MindScape")
            )
            
            container = try ModelContainer(
                for: Session.self,
                SensorReading.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .task {
                    await cleanupUnassignedReadings()
                }
        }
    }
    
    private func cleanupUnassignedReadings() async {
        let context = container.mainContext
        
        let descriptor = FetchDescriptor<SensorReading>(
            predicate: #Predicate<SensorReading> { reading in
                reading.session == nil
            }
        )
        
        do {
            let unassignedReadings = try context.fetch(descriptor)
            for reading in unassignedReadings {
                context.delete(reading)
            }
            try context.save()
            if !unassignedReadings.isEmpty {
                print("Cleaned up \(unassignedReadings.count) unassigned readings")
            }
        } catch {
            print("Failed to cleanup unassigned readings: \(error.localizedDescription)")
        }
    }
}
