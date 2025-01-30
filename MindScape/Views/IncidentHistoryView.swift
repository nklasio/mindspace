import SwiftUI

struct IncidentHistoryView: View {
    @State private var searchText = ""
    @State private var selectedSeverityFilter: String? = nil
    @State private var selectedTimeRange: TimeRange = .week
    
    // Dummy data - would come from persistent storage in real app
    private let incidents = [
        (
            date: Date().addingTimeInterval(-86400),  // Yesterday
            severity: "Moderate",
            time: "3:15 AM",
            heartRate: 92,
            movement: 0.6
        ),
        (
            date: Date().addingTimeInterval(-259200), // 3 days ago
            severity: "Severe",
            time: "2:45 AM",
            heartRate: 115,
            movement: 0.9
        ),
        (
            date: Date().addingTimeInterval(-432000), // 5 days ago
            severity: "Mild",
            time: "4:20 AM",
            heartRate: 82,
            movement: 0.3
        ),
        // Add more historical data
        (
            date: Date().addingTimeInterval(-604800), // 1 week ago
            severity: "Moderate",
            time: "1:30 AM",
            heartRate: 95,
            movement: 0.7
        ),
        (
            date: Date().addingTimeInterval(-691200), // 8 days ago
            severity: "Severe",
            time: "2:20 AM",
            heartRate: 110,
            movement: 0.85
        )
    ]
    
    private var filteredIncidents: [(date: Date, severity: String, time: String, heartRate: Int, movement: Double)] {
        incidents
            .filter { incident in
                // Apply search filter
                if !searchText.isEmpty {
                    let searchLower = searchText.lowercased()
                    return incident.severity.lowercased().contains(searchLower) ||
                           incident.time.lowercased().contains(searchLower)
                }
                return true
            }
            .filter { incident in
                // Apply severity filter
                if let severityFilter = selectedSeverityFilter {
                    return incident.severity == severityFilter
                }
                return true
            }
            .filter { incident in
                // Apply time range filter
                let timeAgo = -incident.date.timeIntervalSinceNow
                switch selectedTimeRange {
                case .day:
                    return timeAgo <= 86400 // 24 hours
                case .week:
                    return timeAgo <= 604800 // 7 days
                case .month:
                    return timeAgo <= 2592000 // 30 days
                case .all:
                    return true
                }
            }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Search and Filter Section
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search incidents", text: $searchText)
                    }
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            // Time Range Pills
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                FilterPill(
                                    title: range.description,
                                    isSelected: selectedTimeRange == range,
                                    color: .blue
                                ) {
                                    selectedTimeRange = range
                                }
                            }
                            
                            Divider()
                                .frame(height: 24)
                                .padding(.horizontal, 4)
                            
                            // Severity Pills
                            ForEach(["Mild", "Moderate", "Severe"], id: \.self) { severity in
                                FilterPill(
                                    title: severity,
                                    isSelected: selectedSeverityFilter == severity,
                                    color: severityColor(severity)
                                ) {
                                    if selectedSeverityFilter == severity {
                                        selectedSeverityFilter = nil
                                    } else {
                                        selectedSeverityFilter = severity
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal)
                
                // Incidents List
                LazyVStack(spacing: 12) {
                    ForEach(filteredIncidents, id: \.date) { incident in
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
                .padding(.horizontal)
            }
        }
        .background(
            LinearGradient(
                colors: [
                    .purple.opacity(0.1),
                    .blue.opacity(0.1),
                    .mint.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Incident History")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func severityColor(_ severity: String) -> Color {
        switch severity {
        case "Mild": return .yellow
        case "Moderate": return .orange
        case "Severe": return .red
        default: return .gray
        }
    }
}

// Helper Views
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? color : color.opacity(0.15))
                )
        }
    }
}

enum TimeRange: CaseIterable {
    case day, week, month, all
    
    var description: String {
        switch self {
        case .day: return "24h"
        case .week: return "Week"
        case .month: return "Month"
        case .all: return "All"
        }
    }
}

#Preview {
    NavigationStack {
        IncidentHistoryView()
    }
} 