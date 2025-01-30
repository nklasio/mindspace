import SwiftUI

struct DummyIncidentRow: View {
    let date: Date
    let severity: String
    let time: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(date, format: .dateTime.weekday().month().day())
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack(spacing: 8) {
                    Text(TimeFormatter.shared.formatTime(time))
                    
                    // Add a subtle separator
                    Circle()
                        .fill(.secondary.opacity(0.3))
                        .frame(width: 3, height: 3)
                    
                    // Duration based on severity
                    Text(getDuration(for: severity))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(severity)
                .font(.subheadline)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(severityColor.opacity(0.2))
                .foregroundStyle(severityColor)
                .clipShape(Capsule())
        }
    }
    
    private func getDuration(for severity: String) -> String {
        switch severity {
        case "Mild": return "1m 45s"
        case "Moderate": return "2m 15s"
        case "Severe": return "3m 30s"
        default: return "N/A"
        }
    }
    
    private var severityColor: Color {
        switch severity {
        case "Mild": return .yellow
        case "Moderate": return .orange
        case "Severe": return .red
        default: return .gray
        }
    }
}
