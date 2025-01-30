import SwiftUI

public func qualityRow(for rate: SamplingRate) -> some View {
    HStack {
        Image(systemName: qualityIcon(for: rate))
            .foregroundStyle(qualityColor(for: rate))
        VStack(alignment: .leading, spacing: 2) {
            Text(rate.rawValue)
                .font(.body)
            Text(rate.recordingTime)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

public func qualityIcon(for rate: SamplingRate) -> String {
    switch rate {
    case .accurate: return "gauge.high"
    case .balanced: return "gauge.medium"
    case .efficient: return "gauge.low"
    }
}

public func qualityColor(for rate: SamplingRate) -> Color {
    switch rate {
    case .accurate: return .green
    case .balanced: return .blue
    case .efficient: return .orange
    }
}

public func qualityExplanation(for rate: SamplingRate) -> some View {
    switch rate {
    case .accurate:
        Text("Captures detailed motion and heart rate data every few seconds.")
    case .balanced:
        Text("Balanced between data quality and battery life.")
    case .efficient:
        Text("Optimized for longer recording sessions with reduced detail.")
    }
} 