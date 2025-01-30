import SwiftUI

struct BatteryStatusView: View {
    @ObservedObject var batteryInfo: BatteryMonitor
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: batteryImage)
                .foregroundColor(batteryColor)
            Text("\(Int(batteryInfo.batteryLevel * 100))%")
                .foregroundColor(batteryColor)
            if batteryInfo.isCharging {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.yellow)
            }
        }
    }
    
    private var batteryImage: String {
        if batteryInfo.isCharging {
            return "battery.100.bolt"
        }
        let level = batteryInfo.batteryLevel
        switch level {
        case 0..<0.25: return "battery.25"
        case 0.25..<0.5: return "battery.50"
        case 0.5..<0.75: return "battery.75"
        default: return "battery.100"
        }
    }
    
    private var batteryColor: Color {
        if batteryInfo.isCharging { return .green }
        let level = batteryInfo.batteryLevel
        switch level {
        case 0..<0.25: return .red
        case 0.25..<0.5: return .orange
        default: return .green
        }
    }
} 