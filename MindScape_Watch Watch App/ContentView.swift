//
//  ContentView.swift
//  MindScape_Watch Watch App
//
//  Created by Niklas Stambor on 29.01.25.
//

import SwiftUI
import HealthKit
import CoreMotion
import WatchKit
import SwiftData



// MARK: - Main View
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var sensorManager: SensorManager
    @StateObject private var batteryMonitor = BatteryMonitor()
    @State private var isRecording = false
    @State private var showDebugInfo = false
    @State private var showSettings = false
    @AppStorage("samplingRate") private var samplingRate = SamplingRate.balanced
    @StateObject private var runtimeManager = ExtendedRuntimeManager.shared
    
    init(modelContext: ModelContext? = nil) {
        _sensorManager = StateObject(wrappedValue: SensorManager())
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                StatusHeader(
                    isRecording: isRecording,
                    samplingRate: samplingRate,
                    batteryInfo: batteryMonitor
                )
                
                if !showDebugInfo {
                    HeartRateDisplay(heartRate: sensorManager.heartRate)
                }
                
                controlButtons
            }
            .padding()
            .sheet(isPresented: $showSettings) {
                SettingsView(samplingRate: $samplingRate, showDebugInfo: $showDebugInfo)
            }
        }
        .onAppear {
            setupNotificationObservers()
        }
    }
    
    private func setupNotificationObservers() {
        print("Setting up notification observers")
        
        NotificationCenter.default.addObserver(
            forName: .startSleepRecording,
            object: nil,
            queue: .main
        ) { notification in
            print("NOTIFICATION: Start recording received")
            if let quality = notification.userInfo?["quality"] as? RecordingQuality {
                print("NOTIFICATION: Quality is \(quality)")
                if !isRecording {
                    print("NOTIFICATION: Starting recording")
                    samplingRate = quality.samplingRate
                    toggleRecording()
                } else {
                    print("NOTIFICATION: Already recording")
                }
            } else {
                print("NOTIFICATION: Failed to get quality from userInfo")
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .stopSleepRecording,
            object: nil,
            queue: .main
        ) { _ in
            print("NOTIFICATION: Stop recording received")
            if isRecording {
                print("NOTIFICATION: Stopping recording")
                toggleRecording()
            } else {
                print("NOTIFICATION: Not recording")
            }
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 20) {
            Spacer()
            RecordButton(isRecording: isRecording, action: toggleRecording)
            
            if !isRecording {
                Button(action: { showSettings = true }) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 50, height: 50)
                        Image(systemName: "gear")
                            .font(.system(size: 20))
                            .foregroundStyle(.gray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.top, 10)
    }
    
    private func toggleRecording() {
        print("Toggle recording called, current state: \(isRecording)")
        withAnimation {
            isRecording.toggle()
            if isRecording {
                print("Starting new session")
                runtimeManager.startSession()
                sensorManager.startNewSession(samplingRate: samplingRate, modelContext: modelContext)
                sensorManager.startUpdates()
                batteryMonitor.startMonitoring()
                NotificationManager.shared.sendRecordingStateNotification(isStarting: true)
            } else {
                print("Stopping session")
                runtimeManager.invalidateSession()
                sensorManager.stopCurrentSession()
                sensorManager.stopUpdates()
                batteryMonitor.stopMonitoring()
                NotificationManager.shared.sendRecordingStateNotification(isStarting: false)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}

@MainActor
private let previewContainer: ModelContainer = {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Session.self,
            SensorReading.self,
            configurations: config
        )
        return container
    } catch {
        fatalError("Failed to create preview container: \(error.localizedDescription)")
    }
}()



