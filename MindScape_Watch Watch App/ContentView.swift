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
            VStack(spacing: 4) {
                Spacer()
                StatusHeader(
                    isRecording: isRecording,
                    samplingRate: samplingRate,
                    batteryInfo: batteryMonitor
                )
                Spacer()
                
                if !showDebugInfo {
                    HStack(spacing: 12) {
                        // Heart Rate Display
                        HeartRateDisplay(heartRate: sensorManager.heartRate)
                        
                        // Blood Oxygen Display
                        VStack {
                            ZStack {
                                Circle()
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                                    .frame(width: 60, height: 60)
                                
                                Circle()
                                    .trim(from: 0, to: min(CGFloat(sensorManager.oxygenLevel) / 100, 1))
                                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                    .frame(width: 60, height: 60)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack(spacing: 0) {
                                    Text("\(Int(sensorManager.oxygenLevel))")
                                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                                        .monospacedDigit()
                                    Text("%")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Text("SpO₂")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    // Debug Info Card
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Sensor Data", systemImage: "waveform.path.ecg")
                                .font(.headline)
                                .foregroundStyle(.purple)
                            
                            Group {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(.red)
                                    Text("\(Int(sensorManager.heartRate)) BPM")
                                        .monospacedDigit()
                                    Spacer()
                                }
                                
                                HStack {
                                    Image(systemName: "lungs.fill")
                                        .foregroundStyle(.blue)
                                    Text("\(Int(sensorManager.oxygenLevel))% SpO₂")
                                        .monospacedDigit()
                                    Spacer()
                                }
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Motion:")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("Rot: \(String(format: "%.2f", sensorManager.rotationRate.x)), \(String(format: "%.2f", sensorManager.rotationRate.y)), \(String(format: "%.2f", sensorManager.rotationRate.z))")
                                        .font(.caption)
                                        .monospacedDigit()
                                    
                                    Text("Acc: \(String(format: "%.2f", sensorManager.userAcceleration.x)), \(String(format: "%.2f", sensorManager.userAcceleration.y)), \(String(format: "%.2f", sensorManager.userAcceleration.z))")
                                        .font(.caption)
                                        .monospacedDigit()
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
                
                
                controlButtons
            }
            .padding(.horizontal)
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
        
        // Create sample data
        let session1 = Session(
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date(),
            isFavorite: true
        )
        
        // Add some sample readings with oxygen levels
        let readings1 = [
            SensorReading(
                timestamp: Date().addingTimeInterval(-3600),
                heartRate: 65,
                oxygenLevel: 98
            ),
            SensorReading(
                timestamp: Date().addingTimeInterval(-1800),
                heartRate: 68,
                oxygenLevel: 97
            ),
            SensorReading(
                timestamp: Date(),
                heartRate: 62,
                oxygenLevel: 98
            )
        ]
        
        container.mainContext.insert(session1)
        readings1.forEach { container.mainContext.insert($0) }
        
        return container
    } catch {
        fatalError("Failed to create preview container: \(error.localizedDescription)")
    }
}()



