import SwiftUI
import Charts

struct SleepSummaryCard: View {
    // Dummy data matching dashboard
    private let dummySession = (
        duration: "7h 23m",
        quality: 96,
        incidents: 0
    )
    
    var body: some View {
        NavigationLink {
            SleepDetailView()
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.indigo)
                    Text("Last Night's Sleep")
                        .font(.headline)
                }
                
                HStack(spacing: 20) {
                    StatView(value: dummySession.duration, label: "Duration")
                        .foregroundStyle(.indigo)
                    StatView(value: "\(dummySession.quality)%", label: "Quality")
                        .foregroundStyle(.mint)
                    StatView(value: "\(dummySession.incidents)", label: "Incidents")
                        .foregroundStyle(.purple)
                }
                
                SleepQualityChart()
                    .frame(height: 100)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .indigo.opacity(0.2), radius: 8)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SleepQualityChart: View {
    var body: some View {
        Chart {
            ForEach(SleepDataPoint.sampleData) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("Quality", point.quality)
                )
                .foregroundStyle(Color.accentColor.gradient)
            }
        }
        .chartYScale(domain: 0...100)
    }
} 