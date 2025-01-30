import SwiftUI

struct NightmareHistoryCard: View {
    // Dummy data matching dashboard and detail views
    private let dummyIncidents = [
        (
            date: Date().addingTimeInterval(-86400),  // Yesterday
            severity: "Moderate",
            time: "3:15 AM",
            heartRate: 92,  // Elevated but not extreme
            movement: 0.6   // Moderate movement
        ),
        (
            date: Date().addingTimeInterval(-259200), // 3 days ago
            severity: "Severe",
            time: "2:45 AM",
            heartRate: 115, // Significantly elevated
            movement: 0.9   // High movement
        ),
        (
            date: Date().addingTimeInterval(-432000), // 5 days ago
            severity: "Mild",
            time: "4:20 AM",
            heartRate: 82,  // Slightly elevated
            movement: 0.3   // Light movement
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .symbolEffect(.pulse)
                    .foregroundStyle(.purple)
                Text("Support History")
                    .font(.headline)
            }
            
            if dummyIncidents.isEmpty {
                Text("No incidents - you're doing great!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(dummyIncidents, id: \.time) { incident in
                    NavigationLink {
                        IncidentDetailView(incident: (
                            time: incident.time,
                            severity: incident.severity,
                            heartRate: incident.heartRate,
                            movement: incident.movement
                        ))
                    } label: {
                        DummyIncidentRow(
                            date: incident.date,
                            severity: incident.severity,
                            time: incident.time
                        )
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
            }
            
            NavigationLink {
                IncidentHistoryView()
            } label: {
                Text("View Complete History")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.purple.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .purple.opacity(0.2), radius: 8)
        )
    }
}


