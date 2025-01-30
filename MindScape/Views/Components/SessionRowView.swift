import SwiftUI

struct SessionRowView: View {
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if session.isFavorite == true {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
                
                Text(TimeFormatter.shared.formatDateTime(session.startTime ?? Date())).font(.headline)
                Spacer()
                Text(duration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let readings = session.readings {
                HStack(spacing: 16) {
                    Label("\(readings.count) samples", systemImage: "waveform.path")
                        .font(.caption)
                    
                    if let avgHR = averageHeartRate {
                        Label("\(Int(avgHR)) BPM avg", systemImage: "heart.fill")
                            .font(.caption)
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var formattedTime: String {
        session.startTime?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown"
    }
    
    private var duration: String {
        guard let start = session.startTime, let end = session.endTime else { return "" }
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return String(format: "%dh %dm", hours, minutes)
    }
    
    private var averageHeartRate: Double? {
        guard let readings = session.readings, !readings.isEmpty else { return nil }
        let sum = readings.compactMap { $0.heartRate }.reduce(0, +)
        return sum / Double(readings.count)
    }
}
