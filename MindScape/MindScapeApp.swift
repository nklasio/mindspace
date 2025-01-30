//
//  MindScapeApp.swift
//  MindScape
//
//  Created by Niklas Stambor on 29.01.25.
//

import SwiftUI
import SwiftData
import AppIntents
import WatchConnectivity

@main
struct MindScapeApp: App, AppShortcutsProvider {
    let container: ModelContainer
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    
    static var shortcutTileColor: ShortcutTileColor = .blue
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartSleepRecordingIntent(),
            phrases: ["Start sleep recording", "Start sleep tracking", "Record my sleep"],
            systemImageName: "moon.zzz.fill"
        )
        
        AppShortcut(
            intent: StopSleepRecordingIntent(),
            phrases: ["Stop sleep recording", "Stop sleep tracking", "End sleep recording"],
            systemImageName: "stop.fill"
        )
    }
    
    init() {
        // Disable CoreData and CloudKit debug logs
        UserDefaults.standard.setValue(false, forKey: "com.apple.CoreData.CloudKitDebug")
        UserDefaults.standard.setValue(false, forKey: "com.apple.CoreData.Logging.stderr")
        UserDefaults.standard.setValue(false, forKey: "com.apple.CoreData.SQLDebug")
        
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
