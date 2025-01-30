import SwiftUI
import Charts
import SwiftData

struct WeeklyStatsCard: View {
    // Dummy data
    private let weeklyStats = (
        avgSleep: "7.2h",
        avgQuality: "92%",
        incidents: "2"
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 24))
                    .symbolEffect(.bounce.up, options: .repeating)
                    .foregroundStyle(.teal)
                Text("Weekly Overview")
                    .font(.headline)
            }
            
            WeeklyChart()
                .frame(height: 150)
            
            HStack(spacing: 20) {
                StatView(value: weeklyStats.avgSleep, label: "Avg. Sleep")
                    .foregroundStyle(.teal)
                StatView(value: weeklyStats.avgQuality, label: "Avg. Quality")
                    .foregroundStyle(.mint)
                StatView(value: weeklyStats.incidents, label: "Incidents")
                    .foregroundStyle(.purple)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .teal.opacity(0.2), radius: 8)
        )
    }
}

struct WeeklyChart: View {
    private var weekData: [(date: Date, quality: Double)] {
        (0..<7).map { day in
            (
                Calendar.current.date(byAdding: .day, value: -day, to: Date())!,
                Double.random(in: 70...95)
            )
        }
    }
    
    var body: some View {
        Chart(weekData, id: \.date) { dataPoint in
            BarMark(
                x: .value("Day", dataPoint.date, unit: .day),
                y: .value("Quality", dataPoint.quality)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.teal, .mint],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(format: .dateTime.weekday())
                    .foregroundStyle(.secondary)
            }
        }
        .chartYAxis {
            AxisMarks { mark in
                AxisValueLabel()
                    .foregroundStyle(.secondary)
            }
        }
    }
} 