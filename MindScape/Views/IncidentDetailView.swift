import SwiftUI
import Charts

struct IncidentDetailView: View {
    let incident: (time: String, severity: String, heartRate: Int, movement: Double)
    
    // Additional dummy data for the incident timeline
    private let timelineData = [
        (time: Date().addingTimeInterval(-180), heartRate: 72, movement: 0.2),
        (time: Date().addingTimeInterval(-120), heartRate: 82, movement: 0.4),
        (time: Date().addingTimeInterval(-60), heartRate: 92, movement: 0.8),
        (time: Date(), heartRate: 72, movement: 0.3)
    ]
    
    private var analysis: (duration: String, hrIncrease: String, movement: String, stage: String) {
        switch incident.severity {
        case "Mild":
            return (
                duration: "1m 45s",
                hrIncrease: "+10 BPM",
                movement: "Light",
                stage: "Light Sleep"
            )
        case "Moderate":
            return (
                duration: "2m 15s",
                hrIncrease: "+20 BPM",
                movement: "Moderate",
                stage: "REM"
            )
        case "Severe":
            return (
                duration: "3m 30s",
                hrIncrease: "+35 BPM",
                movement: "Intense",
                stage: "Deep REM"
            )
        default:
            return (
                duration: "N/A",
                hrIncrease: "N/A",
                movement: "N/A",
                stage: "N/A"
            )
        }
    }
    
    private var recommendations: [(icon: String, title: String, description: String, color: Color)] {
        switch incident.severity {
        case "Mild":
            return [
                (
                    icon: "bed.double.fill",
                    title: "Sleep Position",
                    description: "Consider adjusting your pillow height for better comfort",
                    color: .mint
                ),
                (
                    icon: "moon.stars.fill",
                    title: "Evening Routine",
                    description: "Try some light stretching before bed",
                    color: .indigo
                )
            ]
        case "Moderate":
            return [
                (
                    icon: "thermometer.sun.fill",
                    title: "Sleep Environment",
                    description: "Consider keeping your room slightly cooler",
                    color: .orange
                ),
                (
                    icon: "bed.double.fill",
                    title: "Sleep Position",
                    description: "Try sleeping on your side to reduce discomfort",
                    color: .mint
                )
            ]
        case "Severe":
            return [
                (
                    icon: "brain.head.profile",
                    title: "Relaxation Techniques",
                    description: "Practice deep breathing exercises before sleep",
                    color: .purple
                ),
                (
                    icon: "cup.and.saucer.fill",
                    title: "Evening Habits",
                    description: "Avoid caffeine and heavy meals close to bedtime",
                    color: .brown
                ),
                (
                    icon: "person.2.fill",
                    title: "Support",
                    description: "Consider discussing these episodes with a sleep specialist",
                    color: .blue
                )
            ]
        default:
            return []
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overview Card
                VStack(spacing: 24) {
                    // Top section with time and severity
                    VStack(spacing: 16) {
                        // Time section
                        VStack(spacing: 8) {
                            // Duration
                            Text(analysis.duration)
                                .font(.system(size: 36, weight: .medium))
                                .foregroundStyle(.primary)
                            
                            // Start and End times
                            HStack(spacing: 16) {
                                VStack(spacing: 2) {
                                    Text("Started")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(TimeFormatter.shared.formatTime(incident.time))
                                        .font(.system(.body, weight: .medium))
                                }
                                
                                Rectangle()
                                    .frame(width: 1, height: 24)
                                    .foregroundStyle(.secondary.opacity(0.3))
                                
                                VStack(spacing: 2) {
                                    Text("Ended")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    // Calculate end time based on duration
                                    Text(calculateEndTime(from: incident.time, duration: analysis.duration))
                                        .font(.system(.body, weight: .medium))
                                }
                            }
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 20))
                                .symbolEffect(.pulse, options: .repeating)
                            Text(incident.severity)
                                .font(.headline)
                        }
                        .foregroundStyle(severityColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(severityColor.opacity(0.15))
                        .clipShape(Capsule())
                    }
                    
                    // Quick stats
                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 14))
                                Text("\(incident.heartRate)")
                                    .font(.system(.title3, weight: .medium))
                            }
                            Text("BPM")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .foregroundStyle(.red)
                        
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "figure.walk")
                                    .font(.system(size: 14))
                                Text(String(format: "%.1f", incident.movement))
                                    .font(.system(.title3, weight: .medium))
                            }
                            Text("Movement")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .foregroundStyle(.blue)
                        
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 14))
                                Text(analysis.duration)
                                    .font(.system(.title3, weight: .medium))
                            }
                            Text("Duration")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .foregroundStyle(.purple)
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: severityColor.opacity(0.2), radius: 8)
                )
                
                // Vital Signs Card
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 24))
                            .symbolEffect(.bounce, options: .repeating)
                            .foregroundStyle(.red)
                        Text("Vital Signs")
                            .font(.headline)
                    }
                    
                    IncidentTimelineChart()
                        .frame(height: 180)
                    
                    // Updated stats section with horizontal layout
                    HStack(alignment: .top, spacing: 12) {
                        // Heart Rate Stats
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .center, spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 18))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(incident.heartRate)")
                                        .font(.system(.title2, weight: .medium))
                                    Text("Peak BPM")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Text(analysis.hrIncrease)
                                .font(.subheadline)
                                .foregroundStyle(.red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Movement Stats
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .center, spacing: 8) {
                                Image(systemName: "figure.walk")
                                    .foregroundStyle(.blue)
                                    .font(.system(size: 18))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(format: "%.1f", incident.movement))
                                        .font(.system(.title2, weight: .medium))
                                    Text("Movement")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Text(analysis.movement)
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .red.opacity(0.2), radius: 8)
                )
                
                // Analysis Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.system(size: 24))
                            .symbolEffect(.bounce, options: .repeating)
                            .foregroundStyle(.teal)
                        Text("Analysis")
                            .font(.headline)
                    }
                    
                    VStack(spacing: 12) {
                        InfoRow(icon: "clock.fill", title: "Duration", value: analysis.duration)
                        InfoRow(icon: "heart.fill", title: "Heart Rate Increase", value: analysis.hrIncrease)
                        InfoRow(icon: "figure.walk", title: "Movement Intensity", value: analysis.movement)
                        InfoRow(icon: "moon.zzz.fill", title: "Sleep Stage", value: analysis.stage)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .teal.opacity(0.2), radius: 8)
                )
                
                // Recommendations Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 24))
                            .symbolEffect(.bounce, options: .repeating)
                            .foregroundStyle(.yellow)
                        Text("Recommendations")
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(recommendations, id: \.title) { recommendation in
                            RecommendationRow(
                                icon: recommendation.icon,
                                title: recommendation.title,
                                description: recommendation.description,
                                color: recommendation.color
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .yellow.opacity(0.2), radius: 8)
                )
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [
                    severityColor.opacity(0.1),
                    .red.opacity(0.1),
                    .teal.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var severityColor: Color {
        switch incident.severity {
        case "Mild": return .yellow
        case "Moderate": return .orange
        case "Severe": return .red
        default: return .gray
        }
    }
    
    private func calculateEndTime(from startTime: String, duration: String) -> String {
        guard let durationMinutes = parseDuration(duration) else { return "N/A" }
        return TimeFormatter.shared.formatTimeRange(from: startTime, duration: durationMinutes) ?? "N/A"
    }
    
    private func parseDuration(_ duration: String) -> Int? {
        // Parse duration string like "2m 15s" into total minutes
        let components = duration.components(separatedBy: " ")
        var totalMinutes = 0
        
        for component in components {
            if component.hasSuffix("m") {
                if let minutes = Int(component.dropLast()) {
                    totalMinutes += minutes
                }
            } else if component.hasSuffix("s") {
                if let seconds = Int(component.dropLast()) {
                    totalMinutes += (seconds + 30) / 60 // Round to nearest minute
                }
            }
        }
        
        return totalMinutes
    }
}

struct IncidentTimelineChart: View {
    private let data = stride(from: -180, through: 0, by: 15).map { seconds in
        (
            time: Date().addingTimeInterval(TimeInterval(seconds)),
            heartRate: Double.random(in: 70...95),
            movement: Double.random(in: 0.1...0.9)
        )
    }
    
    var body: some View {
        Chart {
            ForEach(data, id: \.time) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("Heart Rate", point.heartRate)
                )
                .foregroundStyle(.red)
                
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("Movement", point.movement * 100)
                )
                .foregroundStyle(.blue)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .minute)) { value in
                AxisValueLabel(format: .dateTime.minute())
            }
        }
        .chartLegend(position: .top) {
            HStack {
                Text("Heart Rate").foregroundStyle(.red)
                Text("Movement").foregroundStyle(.blue)
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.teal)
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct RecommendationRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .fontWeight(.medium)
                Spacer()
            }
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        IncidentDetailView(incident: (
            time: "3:15 AM",
            severity: "Moderate",
            heartRate: 92,
            movement: 0.8
        ))
    }
} 

