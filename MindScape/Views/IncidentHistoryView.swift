import SwiftUI
import SwiftData

struct IncidentHistoryView: View {
    @Query private var sessions: [Session]
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange {
        case week, month, year
        
        var title: String {
            switch self {
            case .week: return "Past Week"
            case .month: return "Past Month"
            case .year: return "Past Year"
            }
        }
    }
    
    var incidents: [(date: Date, incident: Incident)] {
        sessions.flatMap { session in
            session.incidents?.map { incident in
                (date: incident.timestamp, incident: incident)
            } ?? []
        }
        .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        List {
            Picker("Time Range", selection: $selectedTimeRange) {
                Text("Week").tag(TimeRange.week)
                Text("Month").tag(TimeRange.month)
                Text("Year").tag(TimeRange.year)
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            .padding(.vertical, 8)
            
            ForEach(incidents, id: \.date) { incident in
                IncidentDetailRow(date: incident.date, incident: incident.incident)
            }
        }
        .navigationTitle("Incident History")
    }
}

struct IncidentDetailRow: View {
    let date: Date
    let incident: Incident
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(date, format: .dateTime.month().day())
                    .font(.headline)
                Spacer()
                Text(date, format: .dateTime.hour().minute())
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Label {
                    Text("\(Int(incident.heartRate)) BPM")
                } icon: {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                }
                
                Spacer()
                
                SeverityBadge(severity: incident.severity)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

struct SeverityBadge: View {
    let severity: IncidentSeverity
    
    var color: Color {
        switch severity {
        case .mild: return .yellow
        case .moderate: return .orange
        case .severe: return .red
        }
    }
    
    var body: some View {
        Text(severity.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        IncidentHistoryView()
    }
} 