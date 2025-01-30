import SwiftUI
import Foundation

struct StatusHeader: View {
    let isRecording: Bool
    let samplingRate: SamplingRate
    let batteryInfo: BatteryMonitor
    
    var body: some View {
        if !isRecording {
            HStack(spacing: 12) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.purple)
                
                VStack(alignment: .leading) {
                    Text("Ready for Sleep")
                        .font(.headline)
                    BatteryStatusView(batteryInfo: batteryInfo)
                        .font(.caption2)
                }
            }
            .padding(.top, 5)
        } else {
            HStack(spacing: 12) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 32))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, options: .repeating)
                
                VStack(alignment: .leading) {
                    Text("Sweet Dreams")
                        .font(.headline)
                        .foregroundStyle(.green)
                    Text(samplingRate.description)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
} 