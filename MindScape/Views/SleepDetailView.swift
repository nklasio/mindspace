import SwiftUI
import Charts

struct SleepDetailView: View {
    // Dummy data matching dashboard
    private let sleepData = (
        date: Date().addingTimeInterval(-28800), // 8 hours ago
        duration: "7h 23m",
        quality: 96,
        incidents: [
            (time: "3:15 AM", severity: "Moderate", heartRate: 92, movement: 0.8),
        ]
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overview Card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 24))
                            .symbolEffect(.pulse, options: .repeating)
                            .foregroundStyle(.indigo)
                        Text("Sleep Overview")
                            .font(.headline)
                    }
                    
                    HStack {
                        StatView(value: sleepData.duration, label: "Duration")
                            .foregroundStyle(.indigo)
                        Spacer()
                        StatView(value: "\(sleepData.quality)%", label: "Quality")
                            .foregroundStyle(.mint)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .indigo.opacity(0.2), radius: 8)
                )
                
                // Sleep Stages Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "bed.double.fill")
                            .font(.system(size: 24))
                            .symbolEffect(.bounce, options: .repeating)
                            .foregroundStyle(.mint)
                        Text("Sleep Stages")
                            .font(.headline)
                    }
                    
                    SleepStagesChart()
                        .frame(height: 100)
                    
                    HStack(spacing: 20) {
                        StatView(value: "15%", label: "Deep")
                            .foregroundStyle(.blue)
                        StatView(value: "25%", label: "REM")
                            .foregroundStyle(.purple)
                        StatView(value: "60%", label: "Light")
                            .foregroundStyle(.mint)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .mint.opacity(0.2), radius: 8)
                )
                
                // Heart Rate Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 24))
                            .symbolEffect(.pulse, options: .repeating)
                            .foregroundStyle(.red)
                        Text("Heart Rate")
                            .font(.headline)
                    }
                    
                    HeartRateDetailChart()
                        .frame(height: 200)
                    
                    HStack(spacing: 20) {
                        StatView(value: "64", label: "Min BPM")
                            .foregroundStyle(.red.opacity(0.7))
                        StatView(value: "71", label: "Avg BPM")
                            .foregroundStyle(.red)
                        StatView(value: "92", label: "Max BPM")
                            .foregroundStyle(.red.opacity(0.7))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .red.opacity(0.2), radius: 8)
                )
                
                // Incidents Card
                if !sleepData.incidents.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 24))
                                .symbolEffect(.bounce, options: .repeating)
                                .foregroundStyle(.orange)
                            Text("Detected Events")
                                .font(.headline)
                        }
                        
                        ForEach(sleepData.incidents, id: \.time) { incident in
                            NavigationLink {
                                IncidentDetailView(incident: incident)
                            } label: {
                                DummyIncidentRow(
                                    date: sleepData.date,
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
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .orange.opacity(0.2), radius: 8)
                    )
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [
                    .indigo.opacity(0.1),
                    .mint.opacity(0.1),
                    .red.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Last Night")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailSleepChart: View {
    private let data = stride(from: 0, to: 8*60, by: 5).map { minutes in
        (
            time: Calendar.current.date(byAdding: .minute, value: -minutes, to: Date())!,
            quality: Double.random(in: 85...98)
        )
    }
    
    var body: some View {
        Chart(data, id: \.time) { point in
            LineMark(
                x: .value("Time", point.time),
                y: .value("Quality", point.quality)
            )
            .foregroundStyle(Color.accentColor.gradient)
        }
        .chartYScale(domain: 0...100)
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour)) { value in
                AxisValueLabel(format: .dateTime.hour())
            }
        }
    }
}

struct SleepStagesChart: View {
    private let stages = [
        (start: Date().addingTimeInterval(-28800), end: Date().addingTimeInterval(-25200), stage: "Deep"),
        (start: Date().addingTimeInterval(-25200), end: Date().addingTimeInterval(-21600), stage: "Light"),
        (start: Date().addingTimeInterval(-21600), end: Date().addingTimeInterval(-18000), stage: "REM"),
        (start: Date().addingTimeInterval(-18000), end: Date(), stage: "Light")
    ]
    
    var body: some View {
        Chart(stages, id: \.start) { stage in
            RectangleMark(
                xStart: .value("Start", stage.start),
                xEnd: .value("End", stage.end),
                y: .value("Stage", stage.stage)
            )
            .foregroundStyle(by: .value("Stage", stage.stage))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour)) { value in
                AxisValueLabel(format: .dateTime.hour())
            }
        }
        .chartForegroundStyleScale([
            "Deep": .blue,
            "Light": .green,
            "REM": .purple
        ])
    }
}

struct HeartRateDetailChart: View {
    private let heartRates = stride(from: 0, to: 8*60, by: 5).map { minutes in
        (
            time: Calendar.current.date(byAdding: .minute, value: -minutes, to: Date())!,
            bpm: Double.random(in: 60...75)
        )
    }
    
    var body: some View {
        Chart(heartRates, id: \.time) { reading in
            LineMark(
                x: .value("Time", reading.time),
                y: .value("BPM", reading.bpm)
            )
            .foregroundStyle(.red.gradient)
        }
        .chartYScale(domain: 50...100)
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour)) { value in
                AxisValueLabel(format: .dateTime.hour())
            }
        }
    }
} 