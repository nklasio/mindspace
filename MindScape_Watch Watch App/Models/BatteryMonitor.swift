import SwiftUI

class BatteryMonitor: ObservableObject {
    @Published var batteryLevel: Double = 1.0
    @Published var isCharging: Bool = false
    
    func startMonitoring() {
        // Implementation moved from ContentView
    }
    
    func stopMonitoring() {
        // Implementation moved from ContentView
    }
} 