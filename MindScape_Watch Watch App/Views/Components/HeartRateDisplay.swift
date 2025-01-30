import SwiftUI

struct HeartRateDisplay: View {
    let heartRate: Double
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 4) {
            Text("\(Int(heartRate))")
                .font(.system(size: 54, weight: .semibold))
            Text("BPM")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
        }
    }
} 