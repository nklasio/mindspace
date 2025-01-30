//
//  MindScape_WatchApp.swift
//  MindScape_Watch Watch App
//
//  Created by Niklas Stambor on 29.01.25.
//

import SwiftUI
import SwiftData
import AppIntents
import WatchKit

class BackgroundTaskHandler: NSObject, WKApplicationDelegate {
    static let shared = BackgroundTaskHandler()
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                print("Background: Handling connectivity task")
                // Handle the message
                WatchConnectivityManager.shared.handleBackgroundTask()
                connectivityTask.setTaskCompletedWithSnapshot(false)
                
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    func applicationDidFinishLaunching() {
        print("Watch app finished launching")
    }
    
    func applicationDidBecomeActive() {
        print("Watch app became active")
        ExtendedRuntimeManager.shared.handleAppBecameActive()
    }
    
    func applicationWillResignActive() {
        print("Watch app will resign active")
    }
}

@main
struct MindScape_WatchApp: App, AppShortcutsProvider {
    let container: ModelContainer
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    @WKApplicationDelegateAdaptor(BackgroundTaskHandler.self) var backgroundHandler
    
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
        }
    }
}

