//
//  MindScape_WatchApp.swift
//  MindScape_Watch Watch App
//
//  Created by Niklas Stambor on 29.01.25.
//

import SwiftUI
import SwiftData

@main
struct MindScape_WatchApp: App {
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
        }
    }
}

